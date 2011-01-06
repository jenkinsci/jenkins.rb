Feature: Display default host information

  Scenario: Display default host information if it is setup
    Given I run local executable "hudson" with arguments "list --host localhost --port 3010"
    When I run local executable "hudson" with arguments "default_host"
    Then I should see exactly
      """
      http://localhost:3010
      """

  Scenario: Display warning if never used Hudson.rb before
    When I run local executable "hudson" with arguments "default_host"
    Then I should see exactly
      """
      ERROR: Either use --host or add remote servers.
      """
  
  
  