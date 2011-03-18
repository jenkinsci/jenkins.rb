
Feature: Generating a new Jenkins Ruby Plugin

Creating a new Ruby plugin for Jenkins needs to be as simple as running a single command
that will generate a project skeleton. This skeleton will come complete with git repository and all
the goodies that you need to do your plugin develompent.

Background: Creating a brand new Jenkins Ruby Plugin
  Given I've run "jenkins plugin newplugin"

Scenario: The directory skeleton is generated
  Then I should see this structure
  """
  [-] newplugin
   | [+] .git
   | .gitignore
   | Gemfile
   | Rakefile
   | [-] lib
   | [-] newplugin
   |  |  | version.rb
   |  | newplugin.rb
   | [-] spec
   |  | spec_helper.rb
   | [-] plugin
   |  | [+] models
   |  | [+] views
  """

Scenario: The .gitignore contents
  When I open ".gitignore"
  Then I should see
  """
.bundle
.rvmrc
.rspec
  """

Scenario: The Gemfile contents
  When I open "Gemfile"
  Then I should see
  """
source :rubygems

gem "jenkins-war"
gem "jenkins-plugins"
  """

Scenario: The Rakefile contents
  When I open "Rakefile"
  Then I should see
  """
require 'jenkins/rake'
Jenkins::Rake.install_tasks
  """

Scenario: The plugin module contents
  When I open "lib/newplugin.rb"
  Then I should see
  """
module Newplugin

  def self.start
    #do any startup when this plugin initializes
  end

  def self.stop
    #perform any necessary cleanup when this plugin is shut down.
  end
end
  """

Scenario: The version file is generated
  When I open "lib/newplugin/version.rb"
  Then I should see
  """

module Newplugin
  VERSION = 0.0.1
end
  """
  
Scenario: The spec_helper is created
  When I open "spec/spec_helper.rb"
  Then I should see
  """
  $:.unshift(Pathname(__FILE__).dirname.join('../lib'))
  require 'newplugin'
  """

  