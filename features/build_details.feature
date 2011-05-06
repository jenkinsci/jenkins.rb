Feature: Show build details
  I want to see details about a particular build for a job I'm interested in

  Scenario: Show build details for a job on a non-existent server (jenkins build_details)
    When I run local executable "jenkins" with arguments "build_details ruby 1 --host localhost --port 9999"
    Then I should see exactly
      """
      No connection available to the server.
      """
  
  Scenario: Show build details for a non-existent job (jenkins build_details)
    Given I have a Jenkins server running
    And the Jenkins server has no current jobs
    When I run local executable "jenkins" with arguments "build_details ruby 1 --host localhost --port 3010"
    Then I should see exactly
      """
      ERROR: Cannot find project 'ruby'.
      """
  
  Scenario: Show build details for a job (jenkins build_details)
    Given I have a Jenkins server running
    And the Jenkins server has no current jobs
    And I am in the "ruby" project folder
    And the project uses "git" scm
    When I run local executable "jenkins" with arguments "create . --host localhost --port 3010"
    When I run local executable "jenkins" with arguments "build"
    When I wait for ruby build 1 to start
    When I run local executable "jenkins" with arguments "build_details ruby 1 --host localhost --port 3010 --json"
    Then I should see
      """
      "result":"FAILURE"
      """
    And I should see
      """
      "actions":[
      """
    And I should see
      """
      "changeSet":{
      """
  
  
