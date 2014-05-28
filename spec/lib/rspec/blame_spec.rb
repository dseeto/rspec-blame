require "spec_helper"
require "rspec"
require "rspec/blame"

describe Blame do
  let(:output)    { StringIO.new }

  describe "dump_profile_slowest_examples" do
    before do
      RSpec.configuration.stubs(:profile_examples).returns(1)
      group = RSpec::Core::ExampleGroup.describe("group") { example("example") { sleep 0.001 } }
      group.examples.each { |example| example.execution_result[:run_time] = 0.42 }

      formatter = Blame.new(output)
      formatter.stubs(:examples).returns(group.examples)
      formatter.expects(:`).returns("i0r2i2s5        ( dseeto     2014-05-23      10)")

      formatter.dump_profile_slowest_examples
    end

    it "prints the number of examples to profile" do
      expect(output.string).to match(/Slowest 1 examples/)
    end

    it "prints the time taken for the slowest tests" do
      expect(output.string).to match(/finished in 0\.42 secs/)
    end

    it "prints the name of the examples" do
      expect(output.string).to match(/group example/m)
    end

    it "prints the percentage taken from the total time" do
      expect(output.string).to match(/100.0% of total time/)
    end

    it "prints the path to test example" do
      filename = __FILE__.split(File::SEPARATOR).last
      expect(output.string).to match(/#{filename}\:11/)
    end

    it "prints summary including author, commit, and date" do
      expect(output.string).to match(/Author:.*\(.*\), Date:/)
    end
  end
end
