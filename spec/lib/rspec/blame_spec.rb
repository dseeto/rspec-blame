require "spec_helper"

describe Blame do
  describe "dump_profile_slowest_examples" do
    before(:each) {
      @output = StringIO.new

      @group = RSpec::Core::ExampleGroup.describe("group")
      @fast_example = RSpec::Core::Example.new(@group, "fast example", @group.metadata).tap do |example|
        example.execution_result[:run_time] = 0.1
      end
      @slower_example = RSpec::Core::Example.new(@group, "slower example", @group.metadata).tap do |example|
        example.execution_result[:run_time] = 1
      end
      @slow_example = RSpec::Core::Example.new(@group, "slow example", @group.metadata).tap do |example|
        example.execution_result[:run_time] = 10
      end
      @group.examples << @fast_example << @slower_example << @slow_example

      @formatter = Blame.new(@output).tap do |f|
        f.stubs(:examples).returns(@group.examples)
        f.stubs(:`).returns("i0r2i2s5        ( dseeto     2014-05-23      10)")

      RSpec.configuration.profile_threshold = nil
      end
    }

    it "prints the number of examples to profile" do
      RSpec.configuration.stubs(:profile_examples).returns(2)
      @formatter.dump_profile_slowest_examples

      expect(@output.string).to include("Slowest 2 examples")
    end

    it "prints the example_group size if less than the number of examples to profile" do
      RSpec.configuration.stubs(:profile_examples).returns(10)
      @formatter.dump_profile_slowest_examples

      expected_output = "Slowest #{@group.examples.size} examples"
      expect(@output.string).to include(expected_output)
    end

    it "prints the time taken for the slowest tests" do
      RSpec.configuration.stubs(:profile_examples).returns(1)
      @formatter.dump_profile_slowest_examples

      expect(@output.string).to include("finished in #{@slow_example.execution_result[:run_time]}")
    end

    it "prints the name of the examples" do
      RSpec.configuration.stubs(:profile_examples).returns(2)
      @formatter.dump_profile_slowest_examples

      expect(@output.string).to include("group #{@slow_example.description}")
      expect(@output.string).to include("group #{@slower_example.description}")
    end

    it "prints the percentage taken from the total time" do
      RSpec.configuration.stubs(:profile_examples).returns(3)
      @formatter.dump_profile_slowest_examples

      expect(@output.string).to include("100.0% of total time")
    end

    it "prints the path to test example" do
      RSpec.configuration.stubs(:profile_examples).returns(1)
      @formatter.dump_profile_slowest_examples

      filename = __FILE__.split(File::SEPARATOR).last
      expect(@output.string).to include("#{filename}\:15")
    end

    it "prints summary including author, commit, and date" do
      RSpec.configuration.stubs(:profile_examples).returns(1)
      @formatter.dump_profile_slowest_examples

      expect(@output.string).to match(/Author: .*, Date: .*, Hash:/)
    end

    it "does not print examples if execution time is under profile_threshold" do
      RSpec.configuration.stubs(:profile_examples).returns(10)
      RSpec.configuration.profile_threshold = 5.00
      @formatter.dump_profile_slowest_examples

      expect(@output.string).to include("Slowest 1 example finished in #{@slow_example.execution_result[:run_time]}")
    end
  end

  describe "dump_profile_slowest_example_groups" do
    before(:each) {
      @output = StringIO.new

      @fast_group = RSpec::Core::ExampleGroup.describe("fast group")
      @fast_example = RSpec::Core::Example.new(@fast_group, "fast example", @fast_group.metadata).tap do |example|
        example.execution_result[:run_time] = 0.1
      end
      @fast_group.examples << @fast_example

      @slower_group = RSpec::Core::ExampleGroup.describe("slower group")
      @slower_example = RSpec::Core::Example.new(@slower_group, "slower example", @slower_group.metadata).tap do |example|
        example.execution_result[:run_time] = 1
      end
      @slower_group.examples << @slower_example

      @slow_group = RSpec::Core::ExampleGroup.describe("slow group")
      @slow_example = RSpec::Core::Example.new(@slow_group, "slow example", @slow_group.metadata).tap do |example|
        example.execution_result[:run_time] = 10
      end
      @slow_group.examples << @slow_example

      @formatter = Blame.new(@output).tap do |f|
        f.stubs(:examples).returns(@slow_group.examples.zip(@slower_group.examples, @fast_group.examples).flatten)
        f.stubs(:`).returns("i0r2i2s5        ( dseeto     2014-05-23      10)")

      RSpec.configuration.profile_threshold = nil
      end
    }

    it "prints the number of example_groups to profile" do
      RSpec.configuration.stubs(:profile_examples).returns(2)
      @formatter.dump_profile_slowest_example_groups

      expect(@output.string).to include("Slowest 2 example groups")
    end

    it "prints the number of example_groups if less than the number of examples to profile" do
      RSpec.configuration.stubs(:profile_examples).returns(10)
      @formatter.dump_profile_slowest_example_groups

      expected_output = "Slowest #{@formatter.examples.size} example groups"
      expect(@output.string).to include(expected_output)
    end

    it "prints the average time taken for the slowest example groups" do
      RSpec.configuration.stubs(:profile_examples).returns(1)
      @formatter.dump_profile_slowest_example_groups

      expect(@output.string).to include("10.00 secs avg")
    end

    it "prints the name of the slowest example groups" do
      RSpec.configuration.stubs(:profile_examples).returns(2)
      @formatter.dump_profile_slowest_example_groups

      expect(@output.string).to include("#{@slow_group.description}")
      expect(@output.string).to include("#{@slower_group.description}")
    end

    it "prints the path to test example group" do
      RSpec.configuration.stubs(:profile_examples).returns(1)
      @formatter.dump_profile_slowest_example_groups

      filename = __FILE__.split(File::SEPARATOR).last
      expect(@output.string).to include("#{filename}")
    end

    it "does not print examples if execution time is under profile_threshold" do
      RSpec.configuration.stubs(:profile_examples).returns(10)
      RSpec.configuration.profile_threshold = 15.00
      @formatter.dump_profile_slowest_example_groups

      expect(@output.string).to include ("All example groups are faster than #{@formatter._format_seconds(RSpec.configuration.profile_threshold)} secs.")
    end
  end
end
