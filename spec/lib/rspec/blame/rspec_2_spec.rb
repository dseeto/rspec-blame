require "spec_helper"
require "rspec/blame/rspec_2"

describe Blame do
  let(:output) { StringIO.new }
  let(:formatter) { Blame.new(output) }
  fast_example_line_number, slow_example_line_number = nil, nil

  describe "dump_profile" do
    it "prints profile_threshold if configured" do
      RSpec.configuration.stub(:profile_threshold) { 2 }
      formatter.dump_profile
      expect(output.string).to match(/exceeding the profile threshold \(2\.00 secs\)/)
    end

    it "prints the total time used to profile" do
      formatter.dump_profile
      expect(output.string).to match(/Profiling finished in .+ secs./)
    end
  end

  describe "dump_profile_slowest_examples" do
    before do
      group = RSpec::Core::ExampleGroup.describe("group") do
        example("fast")
        fast_example_line_number = __LINE__ - 1
        example("slow")
        slow_example_line_number = __LINE__ - 1
      end
      runtimes = { "fast" => 3, "slow" => 5 }
      group.examples.each { |e| e.execution_result[:run_time] = runtimes[e.description] }

      formatter.stub(:examples) { group.examples }
      formatter.stub(:`) { ("i0r2i2s5        ( dseeto     2014-05-23      10)") }
      RSpec.configuration.stub(:profile_examples) { 10 }
      RSpec.configuration.stub(:profile_threshold) { nil }
    end

    after do
      RSpec.configuration.profile_examples = false
    end

    it "prints the number of examples to profile" do
      RSpec.configuration.stub(:profile_examples) { 1 }
      formatter.dump_profile_slowest_examples
      expect(output.string).to match(/Slowest 1 example/)
    end

    it "prints the example_group size if less than the number of examples to profile" do
      formatter.dump_profile_slowest_examples
      expect(output.string).to match(/Slowest 2 examples/)
    end

    it "prints the total time taken for the slowest tests" do
      formatter.dump_profile_slowest_examples
      expect(output.string).to match(/finished in 8\.00 secs/)
    end

    it "prints the percentage taken from the total time" do
      formatter.dump_profile_slowest_examples
      expect(output.string).to match(/100\.0% of total time/)
    end

    it "prints the total time taken for all examples" do
      formatter.dump_profile_slowest_examples
      expect(output.string).to match(/total time: 8\.00 secs/)
    end

    it "prints the group and example names" do
      formatter.dump_profile_slowest_examples
      expect(output.string).to match(/group slow/)
      expect(output.string).to match(/group fast/)
    end

    it "prints the time taken for each example" do
      formatter.dump_profile_slowest_examples
      expect(output.string).to match(/5\.00 secs/)
      expect(output.string).to match(/3\.00 secs/)
    end

    it "prints the path to the test example" do
      formatter.dump_profile_slowest_examples
      expect(output.string).to match(/\.\/spec\/lib\/rspec\/blame\/rspec_2_spec\.rb:#{fast_example_line_number}/)
      expect(output.string).to match(/\.\/spec\/lib\/rspec\/blame\/rspec_2_spec\.rb:#{slow_example_line_number}/)
    end

    it "prints summary including author, commit, and date" do
      formatter.dump_profile_slowest_examples
      expect(output.string).to match(/Author: dseeto, Date: 2014-05-23, Hash: i0r2i2s5/)
    end

    it "prints examples if execution time is above the profile_threshold" do
      RSpec.configuration.stub(:profile_threshold) { 4 }
      formatter.dump_profile_slowest_examples
      expect(output.string).to match(/group slow/)
    end

    it "does not print examples if execution time if under the profile_threshold" do
      RSpec.configuration.stub(:profile_threshold) { 4 }
      formatter.dump_profile_slowest_examples
      expect(output.string).to_not match(/group fast/)
    end

    it "states that all examples are faster than the profile threshold when applicable" do
      RSpec.configuration.stub(:profile_threshold) { 1337 }
      formatter.dump_profile_slowest_examples
      expect(output.string).to match(/All examples are faster than 1337\.00 secs/)
    end
  end

  describe "dump_profile_slowest_example_groups" do
    before do
      slow_group = RSpec::Core::ExampleGroup.describe("slow group") do
        example("slow")
        slow_example_line_number = __LINE__ - 1
      end
      fast_group = RSpec::Core::ExampleGroup.describe("fast group") do
        example("fast")
        fast_example_line_number = __LINE__ - 1
      end
      runtimes = { "fast" => 3, "slow" => 5 }
      slow_group.examples.first.execution_result[:run_time] = runtimes["slow"]
      fast_group.examples.first.execution_result[:run_time] = runtimes["fast"]

      formatter.stub(:examples) { slow_group.examples + fast_group.examples }
      formatter.stub(:`) { ("i0r2i2s5        ( dseeto     2014-05-23      10)") }
      RSpec.configuration.stub(:profile_examples) { 10 }
      RSpec.configuration.stub(:profile_threshold) { nil }
    end

    after do
      RSpec.configuration.profile_examples = false
    end

    it "prints the number of example groups to profile" do
      RSpec.configuration.stub(:profile_examples) { 1 }
      formatter.dump_profile_slowest_example_groups
      expect(output.string).to match(/Slowest 1 example group/)
    end

    it "prints the number of example groups if less than the number of examples to profile" do
      formatter.dump_profile_slowest_example_groups
      expect(output.string).to match(/Slowest 2 example groups/)
    end

    it "prints the group name" do
      formatter.dump_profile_slowest_example_groups
      expect(output.string).to match(/slow group/)
      expect(output.string).to match(/fast group/)
    end

    it "prints the avg time taken for each example group" do
      formatter.dump_profile_slowest_example_groups
      expect(output.string).to match(/5\.00 secs avg/)
      expect(output.string).to match(/3\.00 secs avg/)
    end

    it "prints the path to the example group" do
      formatter.dump_profile_slowest_example_groups
      expect(output.string).to match(/\.\/spec\/lib\/rspec\/blame\/rspec_2_spec\.rb/)
      expect(output.string).to match(/\.\/spec\/lib\/rspec\/blame\/rspec_2_spec\.rb/)
    end

    it "prints total execution time and number of examples for each group" do
      formatter.dump_profile_slowest_example_groups
      expect(output.string).to match(/Execution Time: 5\.00 secs, Examples: 1/)
      expect(output.string).to match(/Execution Time: 3\.00 secs, Examples: 1/)
    end

    it "prints example group if execution time is above the profile_threshold" do
      RSpec.configuration.stub(:profile_threshold) { 4 }
      formatter.dump_profile_slowest_example_groups
      expect(output.string).to match(/slow group/)
    end

    it "does not print example group if execution time is under the profile_threshold" do
      RSpec.configuration.stub(:profile_threshold) { 4 }
      formatter.dump_profile_slowest_example_groups
      expect(output.string).to_not match(/fast group/)
    end

    it "states that all example groups are faster than the profile threshold when applicable" do
      RSpec.configuration.stub(:profile_threshold) { 1337 }
      formatter.dump_profile_slowest_example_groups
      expect(output.string).to match(/All example groups are faster than 1337\.00 secs/)
    end
  end
end
