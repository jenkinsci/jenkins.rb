# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "jenkins/plugin/runtime/version"

Gem::Specification.new do |s|
  s.name        = "jenkins-plugin-runtime"
  s.version     = Jenkins::Plugin::Runtime::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Charles Lowell"]
  s.email       = ["cowboyd@thefrontside.net"]
  s.homepage    = "https://github.com/jenkinsci/jenkins.rb/tree/master/ruby-runtime"
  s.summary     = %q{Runtime support libraries for Jenkins Ruby plugins}
  s.description = %q{I'll think of a better description later, but if you're reading this, then I haven't}

  s.rubyforge_project = "jenkins-plugin-runtime"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "json"
  s.add_dependency "slop", "~> 3.0.2"

  s.add_development_dependency "rake", "0.8.7"
  s.add_development_dependency "rspec", "~> 2.7.0" # something in rspec 2.8 breaks rspec-spies
  s.add_development_dependency "rspec-spies"
  s.add_development_dependency "jenkins-war", "~> 1.445"

end
