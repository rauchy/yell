# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "yell/version"

Gem::Specification.new do |s|
  s.name        = "yell"
  s.version     = Yell::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Rudolf Schmidt"]

  s.homepage    = "http://rudionrails.github.com/yell"
  s.summary     = %q{Yell - Your Extensible Logging Library }
  s.description = %q{Yell - Your Extensible Logging Library. Define multiple adapters, various log level combinations or message formatting options like you've never done before}

  s.rubyforge_project = "yell"

  s.files         = `git ls-files`.split($\)
  s.executables   = s.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})

  s.require_paths = ["lib"]
end

