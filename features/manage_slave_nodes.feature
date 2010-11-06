Feature: Adding slave nodes
  In order to have different environments for different projects
  As a developer
  I want to add new slave nodes to my Hudson instance

  Background:
    Given I have a Hudson server running
    And the Hudson server has no slaves
    When I run local executable "hudson" with arguments "nodes --host localhost --port 3010"
    Then I should see exactly
      """
      master
      """

  Scenario: Add slave via API (hudson nodes)
    When I create a new node with the following options on "http://localhost:3010":
      | name       | Slave 1        |
      | label      | app1 app2 app3 |
      | slave_host | foo1.bar.com   |
      | slave_user | hudson         |
    When I run local executable "hudson" with arguments "nodes"
    Then I should see exactly
      """
      master
      Slave 1
      """

  Scenario: Add slave via CLI with name defaulted to URL (hudson add_node)
    When I run local executable "hudson" with arguments "add_node foo1.bar.com --slave-user deploy --label 'app1 app2' --host localhost --port 3010"
    Then I should see exactly
      """
      Added slave node foo1.bar.com
      """
    When I run local executable "hudson" with arguments "nodes"
    Then I should see exactly
      """
      master
      foo1.bar.com
      """