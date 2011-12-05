# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "jenkins/version"

Gem::Specification.new do |s|
  s.name        = "jenkins"
  s.version     = Jenkins::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Charles Lowell", "Nic Williams"]
  s.email       = ["cowboyd@thefrontside.net", "drnicwilliams@gmail.com"]
  s.homepage    = "http://github.com/cowboyd/jenkins.rb"
  s.summary     = %q{Painless Continuous Integration with Jenkins Server}
  s.description = %q{A suite of utilities for bringing continous integration to your projects (not the other way around) with jenkins CI}

  s.rubyforge_project = "jenkins"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency("term-ansicolor", ">= 1.0.4")
  s.add_dependency("httparty", "~> 0.6.1")
  s.add_dependency("builder", "~> 2.1.2")
  s.add_dependency("thor", "~> 0.14.2")
  s.add_dependency("hpricot")
  s.add_dependency("json_pure", ">= 1.5.1")
  s.add_development_dependency("jenkins-war", ">= 1.396")
  s.add_development_dependency("rake", ["~> 0.8.7"])
  s.add_development_dependency("cucumber", ["~> 0.10.0"])
  s.add_development_dependency("rspec", ["~> 2.0.0"])
  s.add_development_dependency("awesome_print")
end
