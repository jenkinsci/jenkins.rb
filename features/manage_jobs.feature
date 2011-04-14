Feature: Create and manage jobs
  In order to reduce cost of getting a new project up onto Jenkins
  As a project developer
  I want to add a new project to Jenkins as a job

  Background:
    Given I have a Jenkins server running
    And the Jenkins server has no current jobs
  
  Scenario: Setup jenkins job for git scm (jenkins create)
    Given I am in the "ruby" project folder
    And the project uses "git" scm
    When I run local executable "jenkins" with arguments "create . --host localhost --port 3010"
    Then I should see exactly
      """
      Added ruby project 'ruby' to Jenkins.
      Triggering initial build...
      Trigger additional builds via:
        URL: http://localhost:3010/job/ruby/build
        CLI: jenkins build ruby
      """
    When I run local executable "jenkins" with arguments "list --host localhost --port 3010"
    Then I should see "ruby"
  
  Scenario: Create job via $JENKINS_HOST and $JENKINS_PORT (jenkins create)
    Given I am in the "ruby" project folder
    And the project uses "git" scm
    And env variable $JENKINS_HOST set to "localhost"
    And env variable $JENKINS_PORT set to "3010"
    When I run local executable "jenkins" with arguments "create ."
    Then I should see "http://localhost:3010/job/ruby/build"
    When I run local executable "jenkins" with arguments "list"
    Then I should see "ruby"
  
  Scenario: Don't trigger initial job build (jenkins create --no-build)
    Given I am in the "ruby" project folder
    And the project uses "git" scm
    When I run local executable "jenkins" with arguments "create . --no-build --host localhost --port 3010"
    Then I should see exactly
      """
      Added ruby project 'ruby' to Jenkins.
      Trigger builds via:
        URL: http://localhost:3010/job/ruby/build
        CLI: jenkins build ruby
      """

  Scenario: Setup jenkins job with explicit scm url/branches (jenkins create --scm URI --scm-branches='master,other')
    Given I am in the "ruby" project folder
    And the project uses "git" scm
    When I run local executable "jenkins" with arguments "create . --scm git://localhost/myapp.git --scm-branches 'master,other' --host localhost --port 3010"
    Then I should see "Added ruby project 'ruby' to Jenkins."
    And the job "ruby" config "scm" should be:
      """
      <scm class="hudson.plugins.git.GitSCM">
          <configVersion>1</configVersion>
          <remoteRepositories>
            <org.spearce.jgit.transport.RemoteConfig>
              <string>origin</string>
              <int>5</int>
              <string>fetch</string>
              <string>+refs/heads/*:refs/remotes/origin/*</string>
              <string>receivepack</string>
              <string>git-upload-pack</string>
              <string>uploadpack</string>
              <string>git-upload-pack</string>
              <string>url</string>
              <string>git://localhost/myapp.git</string>
              <string>tagopt</string>
              <string></string>
            </org.spearce.jgit.transport.RemoteConfig>
          </remoteRepositories>
          <branches>
            <hudson.plugins.git.BranchSpec>
              <name>master</name>
            </hudson.plugins.git.BranchSpec>
            <hudson.plugins.git.BranchSpec>
              <name>other</name>
            </hudson.plugins.git.BranchSpec>
          </branches>
          <localBranch></localBranch>
          <mergeOptions />
          <recursiveSubmodules>false</recursiveSubmodules>
          <doGenerateSubmoduleConfigurations>false</doGenerateSubmoduleConfigurations>
          <authorOrCommitter>false</authorOrCommitter>
          <clean>false</clean>
          <wipeOutWorkspace>false</wipeOutWorkspace>
          <pruneBranches>false</pruneBranches>
          <buildChooser class="hudson.plugins.git.util.DefaultBuildChooser" />
          <gitTool>Default</gitTool>
          <submoduleCfg class="list" />
          <relativeTargetDir></relativeTargetDir>
          <excludedRegions></excludedRegions>
          <excludedUsers></excludedUsers>
        </scm>
      """

  Scenario: Setup jenkins job with multiple rubies (jenkins create --rubies '1.8.7,rbx-head,jruby')
    Given I am in the "ruby" project folder
    And the project uses "git" scm
    When I run local executable "jenkins" with arguments "create . --rubies '1.8.7,rbx-head,jruby' --host localhost --port 3010"
    Then I should see "Added ruby project 'ruby' to Jenkins."
    And the job "ruby" config "axes" should be:
      """
      <axes>
          <hudson.matrix.TextAxis>
            <name>RUBY_VERSION</name>
            <values>
              <string>1.8.7</string>
              <string>rbx-head</string>
              <string>jruby</string>
            </values>
          </hudson.matrix.TextAxis>
        </axes>
      """

  Scenario: Setup jenkins job with multiple rubies and multiple nodes (jenkins create --rubies.. --node_labels..)
    Given I am in the "ruby" project folder
    And the project uses "git" scm
    When I run local executable "jenkins" with arguments "create . --rubies '1.8.7,rbx-head,jruby' --node-labels '1.8.7,ubuntu' --host localhost --port 3010"
    Then I should see "Added ruby project 'ruby' to Jenkins."
    And the job "ruby" config "axes" should be:
      """
      <axes>
          <hudson.matrix.TextAxis>
            <name>RUBY_VERSION</name>
            <values>
              <string>1.8.7</string>
              <string>rbx-head</string>
              <string>jruby</string>
            </values>
          </hudson.matrix.TextAxis>
          <hudson.matrix.LabelAxis>
            <name>label</name>
            <values>
              <string>1.8.7</string>
              <string>ubuntu</string>
            </values>
          </hudson.matrix.LabelAxis>
        </axes>
      """
  
  Scenario: Setup jenkins job for a specific node label (jenkins create --assigned_node)
    Given I am in the "ruby" project folder
    And the project uses "git" scm
    When I run local executable "jenkins" with arguments "create . --assigned_node my_node --host localhost --port 3010"
    Then I should see "Added ruby project 'ruby' to Jenkins."

  Scenario: Select 'rails3' project type (jenkins create --template rails3)
    Given I am in the "rails-3" project folder
    And the project uses "git" scm
    When I run local executable "jenkins" with arguments "create . --template rails3 --host localhost --port 3010"
    Then I should see "Added rails3 project 'rails-3' to Jenkins."

  Scenario: Select 'erlang' project type (jenkins create --template erlang)
    Given I am in the "erlang" project folder
    And the project uses "git" scm
    When I run local executable "jenkins" with arguments "create . --template erlang --host localhost --port 3010"
    Then I should see "Added erlang project 'erlang' to Jenkins."

  Scenario: Create job without default steps (jenkins create --no-template)
    Given I am in the "non-bundler" project folder
    And the project uses "git" scm
    When I run local executable "jenkins" with arguments "create . --no-template --host localhost --port 3010"
    Then I should see "Added project 'non-bundler' to Jenkins."
    And the job "non-bundler" config "builders" should be:
      """
      <builders>
          <hudson.tasks.Shell>
            <command>echo &quot;THERE ARE NO STEPS! Except this one...&quot;</command>
          </hudson.tasks.Shell>
        </builders>
      """

  Scenario: Reject projects that don't use bundler (jenkins create)
    Given I am in the "non-bundler" project folder
    And the project uses "git" scm
    When I run local executable "jenkins" with arguments "create . --host localhost --port 3010"
    Then I should see "Ruby/Rails projects without a Gemfile are currently unsupported."

  Scenario: Attempt to create project without scm (jenkins create)
    Given I am in the "ruby" project folder
    When I run local executable "jenkins" with arguments "create . --host localhost --port 3010"
    Then I should see "Cannot determine project SCM. Currently supported:"

  Scenario: Recreate a job (jenkins create --override)
    Given I am in the "ruby" project folder
    When I create a job
    Then I should see "Added ruby project 'ruby' to Jenkins."
    When I recreate a job
    Then I should see "Added ruby project 'ruby' to Jenkins."

  Scenario: Trigger a job build (jenkins build)
    Given I am in the "ruby" project folder
    When I create a job
    When I run local executable "jenkins" with arguments "build"
    Then I should see "Build for 'ruby' running now..."
  
  Scenario: Trigger a job build on invaild project (jenkins build)
    Given I am in the "ruby" project folder
    When I run local executable "jenkins" with arguments "build . --host localhost --port 3010"
    Then I should see "ERROR: No job 'ruby' on server."
  
  Scenario: Remove a job (jenkins remove)
    Given I am in the "ruby" project folder
    When I create a job
    Then I should see "Added ruby project 'ruby' to Jenkins."
    When I run local executable "jenkins" with arguments "remove ."
    Then I should see "Removed project 'ruby' from Jenkins."
  
  Scenario: Remove a job that doesn't exist gives error (jenkins remove)
    Given I am in the "ruby" project folder
    When I run local executable "jenkins" with arguments "remove . --host localhost --port 3010"
    Then I should see "ERROR: Failed to delete project 'ruby'."
  
