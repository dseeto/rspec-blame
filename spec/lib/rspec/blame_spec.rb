require "spec_helper"

describe Blame do
  describe "dump_profile_slowest_examples" do
    before(:each) do
      @output = StringIO.new
      @group = RSpec::Core::ExampleGroup.describe("group")
      @fast_example = RSpec::Core::Example.new(@group, "fast example", @group.metadata)
      @slower_example = RSpec::Core::Example.new(@group, "slower example", @group.metadata)
      @slow_example = RSpec::Core::Example.new(@group, "slow example", @group.metadata)
      @formatter = Blame.new(@output)

      @fast_example.execution_result[:run_time] = 0.10000
      @slower_example.execution_result[:run_time] = 1.00
      @slow_example.execution_result[:run_time] = 10.00
      @group.examples << @fast_example << @slower_example << @slow_example
      @formatter.stubs(:examples).returns(@group.examples)
      @formatter.stubs(:`).returns("i0r2i2s5        ( dseeto     2014-05-23      10)")
    end

    it "prints the number of examples to profile" do
      RSpec.configuration.stubs(:profile_examples).returns(2)
      @formatter.dump_profile_slowest_examples

      expect(@output.string).to match(/Slowest 2 examples/)
    end

    it "prints the example_group size if less than the number of examples to profile" do
      RSpec.configuration.stubs(:profile_examples).returns(10)
      @formatter.dump_profile_slowest_examples

      expected_output = "Slowest #{@group.examples.size} examples"
      expect(@output.string).to match(expected_output)
    end

    it "prints the time taken for the slowest tests" do
      RSpec.configuration.stubs(:profile_examples).returns(1)
      @formatter.dump_profile_slowest_examples

      expect(@output.string).to match(/finished in #{@slow_example.execution_result[:run_time]}/)
    end

    it "prints the name of the examples" do
      RSpec.configuration.stubs(:profile_examples).returns(2)
      @formatter.dump_profile_slowest_examples

      expect(@output.string).to match(/group #{@slow_example.description}/)
      expect(@output.string).to match(/group #{@slower_example.description}/)
    end

    it "prints the percentage taken from the total time" do
      RSpec.configuration.stubs(:profile_examples).returns(3)
      @formatter.dump_profile_slowest_examples

      expect(@output.string).to match(/100.0% of total time/)
    end

    it "prints the path to test example" do
      RSpec.configuration.stubs(:profile_examples).returns(1)
      @formatter.dump_profile_slowest_examples

      filename = __FILE__.split(File::SEPARATOR).last
      expect(@output.string).to match(/#{filename}\:10/)
    end

    it "prints summary including author, commit, and date" do
      RSpec.configuration.stubs(:profile_examples).returns(1)
      @formatter.dump_profile_slowest_examples

      expect(@output.string).to match(/Author:.*\(.*\), Date:/)
    end

    it "does not print examples if execution time is under profile_threshold" do
      RSpec.configuration.stubs(:profile_examples).returns(10)
      RSpec.configuration.profile_threshold = 5.00
      @formatter.dump_profile_slowest_examples

      expect(@output.string).to match(/Slowest 1 examples greater than #{RSpec.configuration.profile_threshold}/)
    end
  end
end
