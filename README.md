**Yell - Your Extensible Logging Library**

[![Build Status](https://secure.travis-ci.org/rudionrails/yell.png?branch=master)](http://travis-ci.org/rudionrails/yell) 
[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/rudionrails/yell)

Yell works and is tested with ruby 1.8.7, 1.9.x, jruby 1.8 and 1.9 mode, rubinius 1.8 and 1.9 as well as ree.

**If you want to use Yell with Rails, then head over to [yell-rails](https://github.com/rudionrails/yell-rails).**

## Installation

System wide:

```console
gem install yell
```

Or in your Gemfile:

```ruby
gem "yell"
```


## Usage

On the basics, you can use Yell just like any other logging library with a more 
sophisticated message formatter.

```ruby
logger = Yell.new STDOUT

logger.info "Hello World"
#=> "2012-02-29T09:30:00+01:00 [ INFO] 65784 : Hello World"
#    ^                         ^       ^       ^
#    ISO8601 Timestamp         Level   Pid     Message
```

The strength of Yell, however, comes when using multiple adapters. The already built-in 
ones are IO-based and require no further configuration. Also, there are additional ones 
available as separate gems. Please consult the [wiki](https://github.com/rudionrails/yell/wiki) 
on that - they are listed there.

The standard adapters are:

`:stdout` : Messages will be written to STDOUT  
`:stderr` : Messages will be written to STDERR  
`:file` : Messages will be written to a file  
`:datefile` : Messages will be written to a timestamped file  


Here are some short examples on how to combine them:

##### Example: Notice messages go into `STDOUT` and error messages into `STDERR`

```ruby
logger = Yell.new do |l|
  l.adapter STDOUT, :level => [:debug, :info, :warn]
  l.adapter STDERR, :level => [:error, :fatal]
end
```

##### Example: Typical production Logger

We setup a logger that starts passing messages at the `:info` level. Severities 
below `:error` go into the 'production.log', whereas anything higher is written 
into the 'error.log'.

```ruby
logger = Yell.new do |l|
  l.level = :info # will only pass :info and above to the adapters

  l.adapter :datefile, 'production.log', :level => Yell.level.lte(:warn)
  l.adapter :datefile, 'error.log', :level => Yell.level.gte(:error)
end
```

### But I'm used to Log4r and I don't want to move on

One of the really nice features of Log4r is its repository. The following example is 
taken from the official Log4r [documentation](http://log4r.rubyforge.org/manual.html#outofbox).

```ruby
require 'log4r'
include Log4r

# create a logger named 'mylog' that logs to stdout
mylog = Logger.new 'mylog'
mylog.outputters = Outputter.stdout

# later in the code, you can get the logger back
Logger['mylog']
```

With Yell you can do the same thing with less:

```ruby
require 'yell'

# create a logger named 'mylog' that logs to stdout
Yell.new :stdout, :name => 'mylog'

# later in the code, you can get the logger back
Yell['mylog']
```

There is no need to define outputters separately and you don't have to taint 
you global namespace with Yell's subclasses.

### You want any class to have a logger?

Yell provides a general logger that can be accessed *everywhere*. Just
use the :everywhere option when initializing it:

```ruby
Yell.new :stdout, :everywhere => true

some_instance = SomeClass.new
some_instance.logger.info "Hello World"
```

If you prefer to be more picky and have it only in some objects instead
of everywhere, Yell comes with a simple module: +Yell::Loggable+. Simply include this in a class and 
you are good to go.

```ruby
# Before you can use it, you will need to define a logger and 
# provide it with the `:name` of your class.
Yell.new :stdout, :name => 'Foo'

class Foo
  include Yell::Loggable
end

# Now you can log
Foo.new.logger.info "Hello World"
```

It even works with class inheritance:

```ruby
# Given the above example, we inherit from Foo
class Bar < Foo
end

# The logger will fallback to the Foo superclass
Bar.new.logger.info "Hello World"
```


## Further Readings

[How To: Setting The Log Level](https://github.com/rudionrails/yell/wiki/101-setting-the-log-level)  
[How To: Formatting Log Messages](https://github.com/rudionrails/yell/wiki/101-formatting-log-messages)  
[How To: Using Adapters](https://github.com/rudionrails/yell/wiki/101-using-adapters)  
[How To: The Datefile Adapter](https://github.com/rudionrails/yell/wiki/101-the-datefile-adapter)  
[How To: Different Adapters for Different Log Levels](https://github.com/rudionrails/yell/wiki/101-different-adapters-for-different-log-levels)  


### Additional Adapters
[Syslog](https://github.com/rudionrails/yell/wiki/additional-adapters-syslog)  
[Graylog2 (GELF)](https://github.com/rudionrails/yell/wiki/additional-adapters-gelf)  


### Development

[How To: Writing Your Own Adapter](https://github.com/rudionrails/yell/wiki/Writing-your-own-adapter)  

You can find further examples and additional adapters in the [wiki](https://github.com/rudionrails/yell/wiki).
or have a look into the examples folder.


Copyright &copy; 2011-2012 Rudolf Schmidt, released under the MIT license

