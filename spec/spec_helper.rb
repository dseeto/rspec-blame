ENV["RAILS_ENV"] ||= "test"

RSpec.configure do |config|
  config.mock_with :mocha
end
