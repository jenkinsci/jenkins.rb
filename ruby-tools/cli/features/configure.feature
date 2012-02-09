Feature: Configure host connection information

  Scenario: Configure host connection information and check default host and reconfigure
    Given I run local executable "jenkins" with arguments "configure --host localhost --port 3010"
    When I run local executable "jenkins" with arguments "default_host"
    Then I should see exactly
      """
      http://localhost:3010
      """
    Given I run local executable "jenkins" with arguments "configure --host localhost --port 3010 --ssl"
    When I run local executable "jenkins" with arguments "default_host"
    Then I should see exactly
      """
      https://localhost:3010
      """

  Scenario: Configure host connection authentication information and check auth_info and reconfigure
    Given I run local executable "jenkins" with arguments "auth_info"
    Then I should see exactly
      """
      """
    When I run local executable "jenkins" with arguments "configure --username jenkins --password sniknej"
      And I run local executable "jenkins" with arguments "auth_info"
    Then I should see exactly
      """
      username: jenkins
      password: sniknej
      """
    When I run local executable "jenkins" with arguments "configure --username jenkins1 --password 1sniknej"
      And I run local executable "jenkins" with arguments "auth_info"
    Then I should see exactly
      """
      username: jenkins1
      password: 1sniknej
      """

