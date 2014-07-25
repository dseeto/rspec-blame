require "rspec/core/formatters/progress_formatter"
require "rspec/blame/configuration"

# Formatter that ouputs git blame details for the slowest examples.
class Blame < RSpec::Core::Formatters::ProgressFormatter
  # Prints out profile results and profile threshold if set in RSpec.configuration.
  def dump_profile
    start = Time.now
    _print_profile_threshold unless _profile_threshold.nil?
    dump_profile_slowest_examples
    dump_profile_slowest_example_groups
    output.puts "\nProfiling finished in #{_format_seconds(Time.now - start)} secs."
  end

  def _print_profile_threshold
    output.puts "\nPrinting examples and example groups exceeding the profile threshold (#{_format_seconds(_profile_threshold)} secs):"
  end

  # Appends to ProgressFormatter's output by executing git blame in a subprocess and parsing its output.
  def dump_profile_slowest_examples
    slowest_examples = _slowest_examples(examples)

    return output.puts color("\nAll examples are faster than #{_format_seconds(_profile_threshold)} secs.", :green) if _profile_threshold && slowest_examples.empty?

    _print_example_summary(slowest_examples)
    slowest_examples.each do |example|
      _print_example_details(example)
    end
  end

  def _slowest_examples(examples)
    slowest_examples = examples.sort_by(&_example_run_time).reverse.first(_number_of_examples_to_profile)
    _profile_threshold ? slowest_examples.select { |example| _example_run_time.call(example) > _profile_threshold } : slowest_examples
  end

  def _print_example_summary(slowest_examples)
    slowest_tests_time   = _total_time(slowest_examples)
    total_time           = _total_time(examples)
    formatted_percentage = '%.1f' % (slowest_tests_time / total_time * 100)

    number_of_test     = "\nSlowest #{pluralize(slowest_examples.size, "example")} "
    slowest_total_time = "finished in #{_format_seconds(slowest_tests_time)} secs "
    percent_and_total  = "(#{formatted_percentage}% of total time: #{_format_seconds(total_time)} secs).\n"

    output.puts number_of_test +  slowest_total_time + percent_and_total
  end

  def _print_example_details(example)
    output.puts "  #{example.full_description}"
    output.print "#{color("    #{_format_seconds(_example_run_time.call(example))} secs".ljust(19, ' '), :red)}" + " #{color(example.location.ljust(79, ' '), :yellow)}"

    file, line_number = example.location.split(":")
    git_blame_output = %x(git blame -c --date=short -L #{line_number},#{line_number} #{file})
    blame = /(?<commit>\S+)\s*\((?<author>\D+)(?<date>\S+)/.match(git_blame_output)

    if blame.nil?
      output.puts
    else
      commit_details = " Author: #{blame[:author].strip}, Date: #{blame[:date]}, Hash: #{blame[:commit]}"
      output.puts(color(commit_details.ljust(60, ' '), :cyan))
    end
  end

  def _total_time(examples)
    examples.map(&_example_run_time).inject { |sum, time| sum + time }
  end

  # Prints example group profiling result.
  def dump_profile_slowest_example_groups
    slowest_example_groups = _slowest_example_groups(examples)

    return output.puts color("\nAll example groups are faster than #{_format_seconds(_profile_threshold)} secs.", :green) if _profile_threshold && slowest_example_groups.empty?

    _print_example_group_summary(slowest_example_groups)
    slowest_example_groups.each do |location, details|
      _print_example_group_details(location, details)
    end
  end

  def _slowest_example_groups(examples)
    slowest_example_groups = {}
    examples.each do |example|
      location = example.example_group.parent_groups.last.metadata[:example_group][:location]
      slowest_example_groups[location] ||= Hash.new(0)
      slowest_example_groups[location][:total_time]  += example.execution_result[:run_time]
      slowest_example_groups[location][:count]       += 1
      slowest_example_groups[location][:description] = example.example_group.top_level_description unless slowest_example_groups[location].has_key?(:description)
    end
    slowest_example_groups.each { |location, details| details[:average] = details[:total_time].to_f / details[:count] }

    sorted_example_groups = slowest_example_groups.sort_by { |location, details| details[:average] }.reverse.first(_number_of_examples_to_profile)

    _profile_threshold ? sorted_example_groups.select { |location, details| details[:average] > _profile_threshold } : sorted_example_groups
  end

  def _print_example_group_summary(slowest_example_groups)
    output.puts "\nSlowest #{pluralize(slowest_example_groups.size, "example group")}:"
  end

  def _print_example_group_details(location, details)
    output.puts "  #{details[:description]}"

    average = color("#{_format_seconds(details[:average])} secs avg".ljust(15, " "), :red)
    total   = "#{_format_seconds(details[:total_time])} secs"
    count   = "#{details[:count]}"
    calc    = color(" Execution Time: #{total}, Examples: #{count}".ljust(60, " "), :cyan)
    output.puts "    #{average}" + " #{color(location.split(":")[0].ljust(79, ' '), :yellow)}" + calc
  end

  def _example_run_time
    lambda { |example| example.execution_result[:run_time] }
  end

  def _number_of_examples_to_profile
    RSpec.configuration.profile_examples
  end

  def _profile_threshold
    RSpec.configuration.profile_threshold
  end

  def _format_seconds(float)
    formatted = "%.#{float >= 1 ? 2 : 4}f" % float
  end
end
