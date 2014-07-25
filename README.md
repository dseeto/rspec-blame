# rspec-blame

rspec-blame provides a Blame RSpec formatter that outputs the author, commit hash, and
commit date for the slowest examples when profiling with RSpec in a **git** project. It
also allows a profile threshold to be set, only printing examples that exceed the threshold.

### Goals

In an application that has good test coverage and is managed by multiple people, tests are
constantly added and executed. Often, code that result in slow tests can make the development
process slow as well. To avoid this problem, this gem attempts to faciliate good practices
through accomplishing the following goals:

* Output the commit information of the slow tests, allowing the developer who last touched it
and who also has the most recent context to go back and optimize the code.
* Provide the ability to set a threshold of what are considered slow tests, reducing the noise
when profiling.

Happy testing!

### Example Output

```
................

Printing examples and example groups exceeding the profile threshold (0.000001 secs):

Slowest 10 examples finished in 0.0168 secs (77.0% of total time: 0.0219 secs).
  Blame dump_profile_slowest_examples prints the number of examples to profile
    0.0022 secs     ./spec/lib/rspec/blame_spec.rb:28                                               Author: Braintree, Date: 2014-05-28, Hash: c8c20b05
  Blame dump_profile_slowest_example_groups prints the average time taken for the slowest example groups
    0.0021 secs     ./spec/lib/rspec/blame_spec.rb:134                                              Author: dseeto, Date: 2014-07-25, Hash: 7612bbba
  Blame dump_profile_slowest_examples does not print examples if execution time is under profile_threshold
    0.0019 secs     ./spec/lib/rspec/blame_spec.rb:80                                               Author: dseeto, Date: 2014-07-11, Hash: 8afdd0fc
  Blame dump_profile_slowest_examples prints summary including author, commit, and date
    0.0017 secs     ./spec/lib/rspec/blame_spec.rb:73                                               Author: Braintree, Date: 2014-05-28, Hash: c8c20b05
  Blame dump_profile_slowest_examples prints the example_group size if less than the number of examples to profile
    0.0017 secs     ./spec/lib/rspec/blame_spec.rb:35                                               Author: dseeto, Date: 2014-07-11, Hash: 8afdd0fc
  Blame dump_profile_slowest_example_groups prints the name of the slowest example groups
    0.0016 secs     ./spec/lib/rspec/blame_spec.rb:141                                              Author: dseeto, Date: 2014-07-25, Hash: 7612bbba
  Blame dump_profile_slowest_example_groups prints the path to test example group
    0.0015 secs     ./spec/lib/rspec/blame_spec.rb:149                                              Author: dseeto, Date: 2014-07-25, Hash: 7612bbba
  Blame dump_profile_slowest_example_groups prints the number of example_groups to profile
    0.0014 secs     ./spec/lib/rspec/blame_spec.rb:119                                              Author: dseeto, Date: 2014-07-25, Hash: 7612bbba
  Blame dump_profile_slowest_example_groups prints the number of example_groups if less than the number of examples to profile
    0.0014 secs     ./spec/lib/rspec/blame_spec.rb:126                                              Author: dseeto, Date: 2014-07-25, Hash: 7612bbba
  Blame dump_profile_slowest_example_groups does not print examples if execution time is under profile_threshold
    0.0014 secs     ./spec/lib/rspec/blame_spec.rb:157                                              Author: dseeto, Date: 2014-07-25, Hash: 7612bbba

Slowest 2 example groups:
  Blame
    0.0016 secs avg ./spec/lib/rspec/blame_spec.rb                                                  Execution Time: 0.0217 secs, Examples: 14
  RSpec::Core::Configuration
    0.0001 secs avg ./spec/lib/rspec/blame/configuration_spec.rb                                    Execution Time: 0.0002 secs, Examples: 2

Profiling finished in 0.0860 secs.

Finished in 0.02312 seconds
16 examples, 0 failures
```

### Usage

```
gem "rspec-blame"
```

After including the above line in your Gemfile and running `bundle install`, you may set a profile
threshold by adding the following to `spec/spec_herlper.rb`:

```
RSpec.configure do |config|
  config.profile_threshold = 1
end
```

and adding the following to your `.rspec` file:

```
--require "spec_helper"
```

There are several ways to use the formatter:

#### Command Line With Specific Spec Files

```
rspec -p -f Blame file_spec.rb
```

or

```
rspec --profile --format Blame file_spec.rb
```

#### Rake Task

```
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec) { |t| t.rspec_opts = "-p -f Blame" }
```

#### Any Usage of RSpec

Add the following to your `.rspec` file:

```
--profile
--format Blame
```

#### With Spec Helper
Add `require "spec_helper"` to any spec files and add the following to
your spec_helper.rb:

```
Rspec.configure do |config|
  config.profile_examples = true
  config.formatter = Blame
end
```

### Author

[David Seeto](https://github.com/dseeto)

seeto.david@gmail.com
