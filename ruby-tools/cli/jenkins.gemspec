# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "jenkins/version"

Gem::Specification.new do |s|
  s.name        = "jenkins"
  s.version     = Jenkins::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Charles Lowell", "Nic Williams"]
  s.email       = ["cowboyd@thefrontside.net", "drnicwilliams@gmail.com"]
  s.homepage    = "https://github.com/jenkinsci/jenkins.rb/tree/master/ruby-tools/cli"
  s.summary     = %q{Painless Continuous Integration with Jenkins Server}
  s.description = %q{A suite of utilities for bringing continous integration to your projects (not the other way around) with jenkins CI}
  s.required_ruby_version = '>= 1.9.3'
  s.rubyforge_project = "jenkins"

  s.licenses      = ['MIT']
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency("term-ansicolor", ">= 1.3.0")
  s.add_dependency("httparty", "~> 0.7.0") # TODO: fails with >= 0.8.0
  s.add_dependency("builder", ">= 3.2.2")
  s.add_dependency("thor", ">= 0.15.0")
  s.add_dependency("nokogiri")
  s.add_dependency("hpricot", "0.8.4")
  s.add_dependency("json_pure", ">= 1.5.1")

  s.add_development_dependency "jenkins-war", ">= 1.514"
  s.add_development_dependency "rake"
  s.add_development_dependency "cucumber", "~> 1.3.15"
  s.add_development_dependency "rspec", "~> 2.14.1"
  s.add_development_dependency "awesome_print"
end
