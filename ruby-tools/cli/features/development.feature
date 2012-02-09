Feature: Development processes of jenkins itself (rake tasks)

  As a Newgem maintainer or contributor
  I want rake tasks to maintain and release the gem
  So that I can spend time on the tests and code, and not excessive time on maintenance processes
    
  Scenario: Generate RubyGem
    Given this project is active project folder
    When I invoke task "rake clean" so that I start with nothing
    And I invoke task "rake build"
    Then file with name matching "pkg/jenkins-*.gem" is created
    And file with name matching "jenkins.gemspec" is created
    And the file "jenkins.gemspec" is a valid gemspec

