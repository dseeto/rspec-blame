require "spec_helper"

describe RSpec::Core::Configuration do
  it "adds profile_threshold as a customer setting" do
    RSpec.configuration.respond_to?(:profile_threshold).should == true
  end

  it "sets the profile_threshold customer setting" do
    RSpec.configuration.profile_threshold = 3
    RSpec.configuration.profile_threshold.should == 3
  end
end
