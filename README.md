# rspec-blame

rspec-blame provides a Blame RSpec formatter that outputs the author, commit hash, and
commit date for the slowest examples when profiling with RSpec in a **git** project.

### Output

```
......

Slowest 6 examples finished in 0.0074 secs (100.0% of total time: 0.0074 secs).
Blame dump_profile_slowest_examples prints the number of examples to profile
0.0016 secs ./spec/lib/rspec/blame_spec.rb:21                                               Author: dseeto (i0r2i2s5), Date: 2014-05-28
Blame dump_profile_slowest_examples prints summary including author, commit, and date
0.0012 secs ./spec/lib/rspec/blame_spec.rb:42                                               Author: dseeto (i0r2i2s5), Date: 2014-05-28
Blame dump_profile_slowest_examples prints the time taken for the slowest tests
0.0012 secs ./spec/lib/rspec/blame_spec.rb:25                                               Author: dseeto (i0r2i2s5), Date: 2014-05-28
Blame dump_profile_slowest_examples prints the path to test example
0.0012 secs ./spec/lib/rspec/blame_spec.rb:37                                               Author: dseeto (i0r2i2s5), Date: 2014-05-28
Blame dump_profile_slowest_examples prints the percentage taken from the total time
0.0011 secs ./spec/lib/rspec/blame_spec.rb:33                                               Author: dseeto (i0r2i2s5), Date: 2014-05-28
Blame dump_profile_slowest_examples prints the name of the examples
0.0011 secs ./spec/lib/rspec/blame_spec.rb:29                                               Author: dseeto (i0r2i2s5), Date: 2014-05-28

Finished in 0.00792 seconds
6 examples, 0 failures
```

### Usage

```
gem "rspec-blame"
```

After including the above line in your Gemfile and running `bundle install`, there are
several ways to use the formatter:

#### Command Line With Specific Spec Files

```
rspec -p -f Blame file_spec.rb`
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
