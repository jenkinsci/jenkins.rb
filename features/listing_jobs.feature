Feature: Listing jobs
  I want to see the status of jobs on servers I'm interested in

  Scenario: List jobs on a non-existent server
    When I run local executable "hudson" with arguments "list test --host localhost --port 9999"
    Then I should see "localhost:9999 - no connection"
  
  Scenario: List jobs on a server with no jobs
    Given I have a Hudson server running
    And the Hudson server has no current jobs
    When I run local executable "hudson" with arguments "list test --host localhost --port 3010"
    Then I should see "localhost:3010 - no jobs"
  
  Scenario: List jobs on a server with jobs
    Given I have a Hudson server running
    And the Hudson server has no current jobs
    And I am in the "ruby" project folder
    And the project uses "git" scm
    When I run local executable "hudson" with arguments "create . --host localhost --port 3010"
    When I run local executable "hudson" with arguments "list"
    Then I should see "localhost:3010 -"
    Then I should see "ruby"
    When I run local executable "hudson" with arguments "list --host localhost --port 3010"
    Then I should see "localhost:3010 -"
    Then I should see "ruby"
  
  
  
  
