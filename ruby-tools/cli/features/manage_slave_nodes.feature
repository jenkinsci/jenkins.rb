@jenkins-server
Feature: Adding slave nodes
  In order to have different environments for different projects
  As a developer
  I want to add new slave nodes to my Jenkins instance

  Background:
    Given I have a Jenkins server running
    And the Jenkins server has no slaves
    When I run local executable "jenkins" with arguments "nodes --host localhost --port 3010"
    Then I should see exactly
      """
      master
      """

  Scenario: Add slave via API (jenkins nodes)
    When I create a new node with the following options on "http://localhost:3010":
      | name       | Slave 1        |
      | label      | app1 app2 app3 |
      | slave_host | foo1.bar.com   |
      | slave_user | jenkins         |
    When I run local executable "jenkins" with arguments "nodes"
    Then I should see exactly
      """
      master
      Slave 1
      """

  Scenario: Add slave via CLI with name defaulted to URL (jenkins add_node)
    When I run local executable "jenkins" with arguments "add_node foo1.bar.com --slave-user deploy --labels 'app1,app2'"
    Then I should see exactly
      """
      Added slave node 'foo1.bar.com' to foo1.bar.com
      """
    When I run local executable "jenkins" with arguments "add_node foo1.bar.com --slave-user deploy --labels 'app1,app2'"
    Then I should see exactly
      """
      Slave called 'foo1.bar.com' already exists
      ERROR: Failed to add slave node foo1.bar.com
      """
    When I run local executable "jenkins" with arguments "nodes"
    Then I should see exactly
      """
      master
      foo1.bar.com
      """

  @wip
  Scenario: Add a local Vagrant/VirtualBox VM as a slave (jenkins add_node --vagrant)
    Given I am in the "rails-3" project folder
    When I run local executable "jenkins" with arguments "add_node localhost --name rails-3 --vagrant --labels 'app1,app2'"
    Then I should see exactly
      """
      Added slave node 'rails-3' to localhost
      """
    When I run local executable "jenkins" with arguments "nodes"
    Then I should see exactly
      """
      master
      rails-3
      """
    And the Jenkins config "slaves" should be:
      """
      <slaves>
          <slave>
            <name>rails-3</name>
            <description>Automatically created by Jenkins.rb</description>
            <remoteFS>/vagrant/tmp/jenkins-slave/</remoteFS>
            <numExecutors>2</numExecutors>
            <mode>EXCLUSIVE</mode>
            <retentionStrategy class="hudson.slaves.RetentionStrategy$Always" />
            <launcher class="hudson.plugins.sshslaves.SSHLauncher">
              <host>localhost</host>
              <port>2222</port>
              <username>vagrant</username>
              <password>rvDV+OTiBj3UtK5p7sl62Q==</password>
              <privatekey>/Library/Ruby/Gems/1.8/gems/vagrant-0.6.7/keys/vagrant</privatekey>
            </launcher>
            <label>app1 app2</label>
            <nodeProperties />
          </slave>
        </slaves>
      """

  Scenario: Delete slave node via CLI
    When I create a new node with the following options on "http://localhost:3010":
      | name       | remove_me_node        |
      | label      | app1 app2 app3 |
      | slave_host | foo1.bar.com   |
      | slave_user | jenkins         |
    When I run local executable "jenkins" with arguments "delete_node remove_me_node"
    Then I should see exactly
    """
    Deleted slave node remove_me_node from http://localhost:3010
    """
    When I run local executable "jenkins" with arguments "nodes"
    Then I should see exactly
    """
    master
    """
    When I run local executable "jenkins" with arguments "delete_node remove_me_node"
    Then I should see exactly
    """
    ERROR: Failed to delete node remove_me_node from http://localhost:3010
    """
