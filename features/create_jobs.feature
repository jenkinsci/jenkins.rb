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
    When I run local executable "hudson" with arguments "create ."
    Then I should see "Added project 'ruby' to Hudson."
    Then I should see "http://localhost:3010/job/ruby/build"
    When I run local executable "hudson" with arguments "list"
    Then I should see "ruby"
  
  Scenario: Attempt to create project without scm
    Given I am in the "ruby" project folder
    When I run local executable "hudson" with arguments "create ."
    Then I should see "Cannot determine project SCM. Currently supported:"
