require "rspec"
require "mocha"
require "rspec/blame"
require "rspec/blame/configuration"

ENV["RAILS_ENV"] ||= "test"

RSpec.configure do |config|
  config.mock_with :mocha
end
