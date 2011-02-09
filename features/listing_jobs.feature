Feature: Listing jobs
  I want to see the status of jobs on servers I'm interested in

  Scenario: List jobs on a non-existent server (jenkins list)
    When I run local executable "jenkins" with arguments "list --host localhost --port 9999"
    Then I should see exactly
      """
      No connection available to the server.
      """
  
  Scenario: List jobs on a server with no jobs (jenkins list)
    Given I have a Jenkins server running
    And the Jenkins server has no current jobs
    When I run local executable "jenkins" with arguments "list --host localhost --port 3010"
    Then I should see exactly
      """
      http://localhost:3010: no jobs
      """
  
  Scenario: List jobs on a server with jobs (jenkins list)
    Given I have a Jenkins server running
    And the Jenkins server has no current jobs
    And I am in the "ruby" project folder
    And the project uses "git" scm
    When I run local executable "jenkins" with arguments "create . --host localhost --port 3010"
    When I run local executable "jenkins" with arguments "list"
    Then I should see exactly
      """
      http://localhost:3010:
      * ruby

      """
  
  
