Feature: Create jobs
  In order to reduce cost of getting a new project up onto Hudson
  As a project developer
  I want to add a new project to Hudson as a job

  Background:
    Given I have a Hudson server running
    And the Hudson server has no current jobs
  
  Scenario: Discover Ruby project, on git scm, and create job
    Given I am in the "ruby" project folder
    And the project uses "git" scm
    When I run local executable "hudson" with arguments "create . --host localhost --port 3010"
    Then I should see "Added project 'ruby' to Hudson."
    Then I should see "http://localhost:3010/job/ruby/build"
    When I run local executable "hudson" with arguments "list --host localhost --port 3010"
    Then I should see "ruby"
  
  Scenario: Create job via $HUDSON_HOST and $HUDSON_PORT
    Given I am in the "ruby" project folder
    And the project uses "git" scm
    And env variable $HUDSON_HOST set to "localhost"
    And env variable $HUDSON_PORT set to "3010"
    When I run local executable "hudson" with arguments "create ."
    Then I should see "Added project 'ruby' to Hudson."
    Then I should see "http://localhost:3010/job/ruby/build"
    When I run local executable "hudson" with arguments "list"
    Then I should see "ruby"

  Scenario: Attempt to create project without scm
    Given I am in the "ruby" project folder
    When I run local executable "hudson" with arguments "create . --host localhost --port 3010"
    Then I should see "Cannot determine project SCM. Currently supported:"

  Scenario: Trigger a job build
    Given I am in the "ruby" project folder
    When I create a job
    When I run local executable "hudson" with arguments "build"
    Then I should see "Build for 'ruby' running now..."
  
  Scenario: Trigger a job build on invaild project
    Given I am in the "ruby" project folder
    When I run local executable "hudson" with arguments "build . --host localhost --port 3010"
    Then I should see "ERROR: No job 'ruby' on server."
  
  Scenario: Recreate a job
    Given I am in the "ruby" project folder
    When I create a job
    Then I should see "Added project 'ruby' to Hudson."
    When I recreate a job
    Then I should see "Added project 'ruby' to Hudson."
  
  Scenario: Remove a job
    Given I am in the "ruby" project folder
    When I create a job
    Then I should see "Added project 'ruby' to Hudson."
    When I run local executable "hudson" with arguments "remove ."
    Then I should see "Removed project 'ruby' from Hudson."
  
  Scenario: Remove a job that doesn't exist gives error
    Given I am in the "ruby" project folder
    When I run local executable "hudson" with arguments "remove . --host localhost --port 3010"
    Then I should see "ERROR: Failed to delete project 'ruby'."
  
  
  