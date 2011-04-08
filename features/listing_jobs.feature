Feature: Listing jobs
  I want to see the status of jobs on servers I'm interested in

  Scenario: List jobs on a non-existent server (hudson list)
    When I run local executable "hudson" with arguments "list --host localhost --port 9999"
    Then I should see exactly
      """
      No connection available to the server.
      """
  
  Scenario: List jobs on a server with no jobs (hudson list)
    Given I have a Hudson server running
    And the Hudson server has no current jobs
    When I run local executable "hudson" with arguments "list --host localhost --port 3010"
    Then I should see exactly
      """
      http://localhost:3010: no jobs
      """
  
  Scenario: List jobs on a server with jobs (hudson list)
    Given I have a Hudson server running
    And the Hudson server has no current jobs
    And I am in the "ruby" project folder
    And the project uses "git" scm
    When I run local executable "hudson" with arguments "create . --host localhost --port 3010"
    When I run local executable "hudson" with arguments "list"
    Then I should see exactly
      """
      http://localhost:3010:
      * ruby

      """
  
  
