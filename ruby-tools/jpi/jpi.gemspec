# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "jenkins/plugin/version"

Gem::Specification.new do |s|
  s.name        = "jpi"
  s.version     = Jenkins::Plugin::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Charles Lowell", "Jørgen P. Tjernø", "Kohsuke Kawaguchi"]
  s.email       = ["cowboyd@thefrontside.net"]
  s.homepage    = "https://github.com/jenkinsci/jenkins.rb/tree/master/ruby-tools/jpi"
  s.summary     = %q{Tools for creating and building Jenkins Ruby plugins}
  s.description = %q{Allows you to generate a new Ruby plugin project, build it, test it in Jenkins and release it to the Jenkins Update Center.}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = ['jpi']
  s.require_paths = ["lib"]

  s.add_dependency "bundler"
  s.add_dependency "thor"
  s.add_dependency "rubyzip", "~> 1.1.0"
  s.add_dependency "jenkins-war", "> 1.427"
  s.add_dependency "jenkins-plugin-runtime", "~> #{Jenkins::Plugin::RUNTIME_VERSION_DEPENDENCY}"

  s.add_development_dependency "rake"
  s.add_development_dependency "cucumber"
  s.add_development_dependency "aruba"
end
