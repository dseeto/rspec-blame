Gem::Specification.new do |s|
  s.name        = "rspec-blame"
  s.version     = "0.2.1"
  s.license     = "MIT"

  s.authors     = ["David Seeto"]
  s.email       = "seeto.david@gmail.com"
  s.homepage    = "https://github.com/dseeto/rspec-blame"

  s.summary     = "Git blame when profiling your slowest RSpec examples."
  s.description = %q{rspec-blame provides a Blame formatter that outputs git blame details for the slowest examples above a profile threshold when profiling with RSpec.}
  s.files       = `git ls-files`.split("\n")

  s.add_runtime_dependency     "rspec-core", ["~> 2.14"]
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  s.add_development_dependency "mocha"
end
