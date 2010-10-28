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
    When I run local executable "hudson" with arguments "add_remote test --host localhost --port 3010"
    And I run local executable "hudson" with arguments "list"
    Then I should not see "Either use --host or add remote servers."
    And I should see "test [localhost:3010] - no jobs"

  Scenario: Add a few remote servers
    When I run local executable "hudson" with arguments "add_remote test --host localhost --port 3010"
    And I run local executable "hudson" with arguments "add_remote another --host localhost --port 4000"
    And I run local executable "hudson" with arguments "list"
    Then I should not see "Either use --host or add remote servers."
    And I should see "test [localhost:3010] - no jobs"
    And I should see "another [localhost:3011] - no connection"

  Scenario: Add a remote server and access by abbreviation
    When I run local executable "hudson" with arguments "add_remote test --host localhost --port 3010"
    And I run local executable "hudson" with arguments "add_remote another --host another.host"
    And I run local executable "hudson" with arguments "list --server local"
    Then I should not see "Either use --host or add remote servers."
    And I should see "test [localhost:3010] - no jobs"
    And I should not see "another"
    
