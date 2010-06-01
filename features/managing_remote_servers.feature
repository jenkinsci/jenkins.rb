@wip
Feature: Managing remote servers
  In order to reduce cost of referencing remote servers by explicit --host/--port options
  As a user
  I want a directory of remote servers I frequently use

  Background:
    Given I have a Hudson server running
    And the Hudson server has no current jobs
  
  Scenario: No remote servers
    When I run local executable "hudson" with arguments "list"
    Then I should see "Either use --host or add remote servers."
  
  Scenario: Add a remote server
    When I run local executable "hudson" with arguments "remotes add --host localhost --port 3010"
    And I run local executable "hudson" with arguments "remotes add --host localhost --port 3011"
    And I run local executable "hudson" with arguments "list"
    Then I should not see "Either use --host or add remote servers."
    And I should see "localhost:3010 -"
    And I should see "No jobs"
    And I should see "localhost:3011 - no connection"

  Scenario: Add a remote server and access by abbreviation
    When I run local executable "hudson" with arguments "remotes add --host localhost --port 3010"
    When I run local executable "hudson" with arguments "remotes add --host another.server"
    And I run local executable "hudson" with arguments "list --server local"
    And I should see "localhost:3010 -"
    And I should see "No jobs"
    And I should not see "another.server"
    
