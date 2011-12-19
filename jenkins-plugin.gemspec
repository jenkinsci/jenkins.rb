# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "jenkins/plugin/version"

Gem::Specification.new do |s|
  s.name        = "jenkins-plugin"
  s.version     = Jenkins::Plugin::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Charles Lowell"]
  s.email       = ["cowboyd@thefrontside.net"]
  s.homepage    = "http://github.com/cowboyd/jenkins-plugin"
  s.summary     = %q{DEPRECATED - Tools for creating and building Jenkins Ruby plugins}
  s.description = %q{This gem has moved. Further development will be done on the `jpi` gem}
  s.post_install_message = File.read File.expand_path "lib/jenkins/plugin/PSA.txt"

  s.rubyforge_project = "jenkins-plugin"

  s.files         = `git ls-files`.split("\n")
end
