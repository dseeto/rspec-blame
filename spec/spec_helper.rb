require "rspec"
require "rspec/blame"
require "rspec/blame/configuration"

ENV["RAILS_ENV"] ||= "test"

RSpec.configure do |config|
  config.profile_threshold = 0
end
