module RSpec
  lib = File.expand_path(File.dirname(File.dirname(__FILE__)))
  $LOAD_PATH << lib unless $LOAD_PATH.include?(lib)

  if defined?(::RSpec::Core) && ::RSpec::Core::Version::STRING >= '3.0.0'
    require "rspec/blame/rspec_3"
  else
    require "rspec/blame/rspec_2"
  end
end
