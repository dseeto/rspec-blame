require "rspec/core/formatters/progress_formatter"
require "rspec/blame/configuration"

# Formatter for providing profile output
class Blame < RSpec::Core::Formatters::ProgressFormatter
  Formatters.register self, :dump_profile

  def initialize(output)
    @output = output
  end

  attr_reader :output

  def dump_profile(profile)
    start = Time.now
    _print_profile_threshold unless _profile_threshold.nil?
    dump_profile_slowest_examples(profile)
    dump_profile_slowest_example_groups(profile)
    @output.puts "\nProfiling finished in #{_format_seconds(Time.now - start)} secs."
  end

  def _print_profile_threshold
    @output.puts "\nPrinting examples and example groups exceeding the profile threshold (#{_format_seconds(_profile_threshold)} secs):"
  end

  def dump_profile_slowest_examples(profile)
    slowest_examples = _profile_threshold ? profile.slowest_examples.select { |examples| _example_run_time.call(example) > _profile_threshold } : profile.slowest_examples

    return @output.puts "\nAll examples are faster than #{_format_seconds(_profile_threshold)} secs."  if _profile_threshold && slowest_examples.empty?

    @output.puts "\nSlowest #{pluralize(slowest_examples.size, "example")} finished in (#{_format_seconds(_total_time(slowest_examples))} secs (#{profile.percentage}% of total time): #{_format_seconds(profile.duration)}\n"

    slowest_examples.each do |example|
      _print_example_details(example)
    end
  end

  def _print_example_details(example)
    output.puts "  #{example.full_description}"
    output.print "    #{_format_seconds(_example_run_time.call(example))} secs".ljust(19, ' ') + " #{format_caller(example.location)}".ljust(79, ' ')

    file, line_number = example.location.split(":")
    git_blame_output = %x(git blame -c --date=short -L #{line_number},#{line_number} #{file})
    blame = /(?<commit>\S+)\s*\((?<author>\D+)(?<date>\S+)/.match(git_blame_output)

    if blame.nil?
      output.puts
    else
      commit_details = " Author: #{blame[:author].strip}, Date: #{blame[:date]}, Hash: #{blame[:commit]}"
      output.puts(commit_details.ljust(60, ' '))
    end
  end

  def dump_profile_slowest_example_groups(profile)
    return if profile.slowest_groups.empty?

    @output.puts "\nTop #{profile.slowest_groups.size} slowest example groups:"
    profile.slowest_groups.each do |loc, hash|
      average = "#{bold(Helpers.format_seconds(hash[:average]))} #{bold("seconds")} average"
      total   = "#{Helpers.format_seconds(hash[:total_time])} seconds"
      count   = Helpers.pluralize(hash[:count], "example")
      @output.puts "  #{hash[:description]}"
      @output.puts "    #{average} (#{total} / #{count}) #{loc}"
    end
  end

  def format_caller(caller_info)
    RSpec.configuration.backtrace_formatter.backtrace_line(caller_info.to_s.split(':in `block').first)
  end

  def bold(text)
    ConsoleCodes.wrap(text, :bold)
  end

  def _total_time(examples)
    examples.map(&_example_run_time).inject { |sum, time| sum + time }
  end

  def _example_run_time
    lambda { |example| example.execution_result.run_time }
  end

  def _profile_threshold
    RSpec.configuration.profile_threshold
  end

  def _format_seconds(float)
    formatted = "%.#{float >= 1 ? 2 : 4}f" % float
  end
end
