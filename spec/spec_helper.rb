require "rspec/blame"

ENV["RAILS_ENV"] ||= "test"

RSpec.configure do |config|
  config.profile_examples = true
  config.formatter = Blame
  config.mock_with :mocha
end
