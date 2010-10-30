Feature: Adding slave nodes
  In order to have different environments for different projects
  As a developer
  I want to add new slave nodes to my Hudson instance

  Background:
    Given I have a Hudson server running
    And the Hudson server has no slaves

  Scenario: Add a slave with no authentication required (hudson nodes)
    When I run local executable "hudson" with arguments "nodes --host localhost --port 3010"
    Then I should see exactly
      """
      master
      """

    When I create a new node with the following options on "http://localhost:3010":
      | name       | Slave 1        |
      | label      | app1 app2 app3 |
      | slave_host | foo1.bar.com   |
      | slave_user | hudson         |
    When I run local executable "hudson" with arguments "nodes --host localhost --port 3010"
    Then I should see exactly
      """
      master
      Slave 1
      """