
Feature: Generating a new Jenkins Ruby Plugin

Creating a new Ruby plugin for Jenkins needs to be as simple as running a single command
that will generate a project skeleton. This skeleton will come complete with git repository and all
the goodies that you need to do your plugin develompent.

Scenario: The directory skeleton is generated
    When I run `jpi new cuke-plugin`
  Then I should see this structure
  """
  [-] cuke-plugin
   | [+] .git
   | .gitignore
   | Gemfile
   | Rakefile
   | cuke-plugin.pluginspec
  """
