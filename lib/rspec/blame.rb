require "rspec/core/formatters/progress_formatter"
require "rspec/blame/configuration"

# Formatter that ouputs git blame details for the slowest examples.
class Blame < RSpec::Core::Formatters::ProgressFormatter
  # Appends to ProgressFormatter's output by executing git blame in a subprocess and parsing its output.
  def dump_profile_slowest_examples
    slowest_examples = _slowest_examples(examples)

    _print_summary(slowest_examples)
    slowest_examples.each do |example|
      _print_details(example)
    end
  end

  def dump_profile_slowest_example_groups
    number_of_examples = RSpec.configuration.profile_examples
    example_groups = {}
    examples.each do |example|
      location = example.example_group.parent_groups.last.metadata[:example_group][:location]
      example_groups[location] ||= Hash.new(0)
      example_groups[location][:total_time]  += example.execution_result[:run_time]
      example_groups[location][:count]       += 1
      example_groups[location][:description] = example.example_group.top_level_description unless example_groups[location].has_key?(:description)
    end
    # stop if we've only one example group
    return if example_groups.keys.length <= 1
    example_groups.each do |loc, hash|
      hash[:average] = hash[:total_time].to_f / hash[:count]
    end
    sorted_groups = example_groups.sort_by {|_, hash| -hash[:average]}.first(number_of_examples)
    output.puts "Profiling #{sorted_groups.size} groups."
    sorted_groups = _profile_threshold ? sorted_groups.select { |loc, hash| hash[:average] >= _profile_threshold } : sorted_groups
    output.puts "Found #{sorted_groups.size} groups greater than #{_profile_threshold} secs."
    output.puts "\nTop #{sorted_groups.size} slowest example groups:"
    sorted_groups.each do |loc, hash|
      average = "#{failure_color(format_seconds(hash[:average]))} #{failure_color("seconds")} average"
      total   = "#{format_seconds(hash[:total_time])} seconds"
      count   = pluralize(hash[:count], "example")
      output.puts "  #{hash[:description]}"
      output.puts detail_color("    #{average} (#{total} / #{count}) #{loc}")
    end
  end

  def _slowest_examples(examples)
    number_of_examples_to_profile = RSpec.configuration.profile_examples
    slowest_examples = examples.sort_by(&_example_run_time).reverse.first(number_of_examples_to_profile)
    _profile_threshold ? slowest_examples.select { |example| _example_run_time.call(example) >= _profile_threshold } : slowest_examples
  end

  def _print_summary(slowest_examples)
    slowest_tests_time = _total_time(slowest_examples)
    total_time = _total_time(examples)
    formatted_percentage = '%.1f' % (slowest_tests_time / total_time * 100)

    number_of_test = "\nSlowest #{slowest_examples.size} examples "
    profile_threshold = "#{_profile_threshold ? "greater than #{_format_seconds(_profile_threshold)} secs " : ""}"
    slowest_total_time = "finished in #{_format_seconds(slowest_tests_time)} secs "
    percent_and_total = "(#{formatted_percentage}% of total time: #{_format_seconds(total_time)} secs).\n"

    output.puts number_of_test + profile_threshold + slowest_total_time + percent_and_total
  end

  def _print_details(example)
    output.puts "  #{example.full_description}"
    output.print "%s %s" % [
      color("#{_format_seconds(_example_run_time.call(example))} secs".rjust(15, ' '), :red),
      color(example.location.ljust(80, ' '), :yellow)
    ]

    file, line_number = example.location.split(":")
    git_blame_output = %x(git blame -c --date=short -L #{line_number},#{line_number} #{file})
    blame = /(?<commit>\S+)\s*\((?<author>\D+)(?<date>\S+)/.match(git_blame_output)

    if blame.nil?
      output.puts
    else
      commit_details = "Author: #{blame[:author].strip} (#{blame[:commit]}), Date: #{blame[:date]}"
      output.puts(color(commit_details.ljust(60, ' '), :cyan))
    end
  end

  def _total_time(examples)
    examples.map(&_example_run_time).inject { |sum, time| sum + time }
  end

  def _example_run_time
    lambda { |example| example.execution_result[:run_time] }
  end

  def _profile_threshold
    RSpec.configuration.profile_threshold
  end

  def _format_seconds(float)
    formatted = "%.#{float > 0 ? 2 : 5}f" % float
  end
end
