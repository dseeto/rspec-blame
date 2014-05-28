require "rspec/core/formatters/progress_formatter"

# Formatter that ouputs git blame details for the slowest examples.
# Requirements: Project must be version controlled with git.
# Usage: `rspec --profile --formatter Blame rspec_file.rb` or `rspec -p -f Blame rspec_file.rb`
# Alternative Usage: require "rspec/blame"; RSpec::Core::RakeTask.new(:task) { |t| t.rspec_opts = "-p -f Blame" }
class Blame < RSpec::Core::Formatters::ProgressFormatter
  # Overrides ProgressFormatter's output.
  def dump_profile_slowest_examples
    number_of_examples_to_profile = RSpec.configuration.profile_examples

    slowest_examples = examples.sort_by(&_example_run_time).reverse.first(number_of_examples_to_profile)

    _print_summary_for(slowest_examples)
    slowest_examples.each do |example|
      _print_details_for(example)
    end
  end

  def _print_summary_for(slowest_examples)
    slowest_tests_time, total_time = slowest_examples.map(&_example_run_time).inject { |sum, time| sum + time }, examples.map(&_example_run_time).inject { |sum, time| sum + time }
    formatted_percentage = '%.1f' % (slowest_tests_time / total_time * 100)

    output.puts "\nSlowest #{slowest_examples.size} examples finished in #{format_seconds(slowest_tests_time, 4)} secs (#{formatted_percentage}% of total time: #{format_seconds(total_time, 4)} secs).\n"
  end

  def _example_run_time
    lambda { |example| example.execution_result[:run_time] }
  end

  def _print_details_for(example)
    output.puts "  #{example.full_description}"
    output.print "%s %s" % [
      color("#{format_seconds(_example_run_time.call(example), 4)} secs".rjust(15, ' '), :red),
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
end
