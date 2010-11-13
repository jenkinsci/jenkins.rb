Feature: Create and manage jobs
  In order to reduce cost of getting a new project up onto Hudson
  As a project developer
  I want to add a new project to Hudson as a job

  Background:
    Given I have a Hudson server running
    And the Hudson server has no current jobs
  
  Scenario: Setup hudson job for git scm (hudson create)
    Given I am in the "ruby" project folder
    And the project uses "git" scm
    When I run local executable "hudson" with arguments "create . --host localhost --port 3010"
    Then I should see exactly
      """
      Added ruby project 'ruby' to Hudson.
      Triggering initial build...
      Trigger additional builds via:
        URL: http://localhost:3010/job/ruby/build
        CLI: hudson build ruby
      """
    When I run local executable "hudson" with arguments "list --host localhost --port 3010"
    Then I should see "ruby"
  
  Scenario: Create job via $HUDSON_HOST and $HUDSON_PORT (hudson create)
    Given I am in the "ruby" project folder
    And the project uses "git" scm
    And env variable $HUDSON_HOST set to "localhost"
    And env variable $HUDSON_PORT set to "3010"
    When I run local executable "hudson" with arguments "create ."
    Then I should see "http://localhost:3010/job/ruby/build"
    When I run local executable "hudson" with arguments "list"
    Then I should see "ruby"
  
  Scenario: Don't trigger initial job build (hudson create --no-build)
    Given I am in the "ruby" project folder
    And the project uses "git" scm
    When I run local executable "hudson" with arguments "create . --no-build --host localhost --port 3010"
    Then I should see exactly
      """
      Added ruby project 'ruby' to Hudson.
      Trigger builds via:
        URL: http://localhost:3010/job/ruby/build
        CLI: hudson build ruby
      """

  Scenario: Setup hudson job with explicit scm url/branches (hudson create --scm URI --scm-branches='master,other')
    Given I am in the "ruby" project folder
    And the project uses "git" scm
    When I run local executable "hudson" with arguments "create . --scm git://localhost/myapp.git --scm-branches 'master,other' --host localhost --port 3010"
    Then I should see "Added ruby project 'ruby' to Hudson."
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
          <buildChooser class="hudson.plugins.git.util.DefaultBuildChooser" />
          <gitTool>Default</gitTool>
          <submoduleCfg class="list" />
          <relativeTargetDir></relativeTargetDir>
          <excludedRegions></excludedRegions>
          <excludedUsers></excludedUsers>
        </scm>
      """

  Scenario: Setup hudson job with multiple rubies (hudson create --rubies '1.8.7,rbx-head,jruby')
    Given I am in the "ruby" project folder
    And the project uses "git" scm
    When I run local executable "hudson" with arguments "create . --rubies '1.8.7,rbx-head,jruby' --host localhost --port 3010"
    Then I should see "Added ruby project 'ruby' to Hudson."
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

  Scenario: Setup hudson job with multiple rubies and multiple nodes (hudson create --rubies.. --node_labels..)
    Given I am in the "ruby" project folder
    And the project uses "git" scm
    When I run local executable "hudson" with arguments "create . --rubies '1.8.7,rbx-head,jruby' --node-labels '1.8.7,ubuntu' --host localhost --port 3010"
    Then I should see "Added ruby project 'ruby' to Hudson."
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
  
  Scenario: Setup hudson job for a specific node label (hudson create --assigned_node)
    Given I am in the "ruby" project folder
    And the project uses "git" scm
    When I run local executable "hudson" with arguments "create . --assigned_node my_node --host localhost --port 3010"
    Then I should see "Added ruby project 'ruby' to Hudson."

  Scenario: Select 'rails3' project type (hudson create --template rails3)
    Given I am in the "rails-3" project folder
    And the project uses "git" scm
    When I run local executable "hudson" with arguments "create . --template rails3 --host localhost --port 3010"
    Then I should see "Added rails3 project 'rails-3' to Hudson."

  Scenario: Create job without default steps (hudson create --no-template)
    Given I am in the "non-bundler" project folder
    And the project uses "git" scm
    When I run local executable "hudson" with arguments "create . --no-template --host localhost --port 3010"
    Then I should see "Added project 'non-bundler' to Hudson."
    And the job "non-bundler" config "builders" should be:
      """
      <builders>
          <hudson.tasks.Shell>
            <command>echo &quot;THERE ARE NO STEPS! Except this one...&quot;</command>
          </hudson.tasks.Shell>
        </builders>
      """

  Scenario: Reject projects that don't use bundler (hudson create)
    Given I am in the "non-bundler" project folder
    And the project uses "git" scm
    When I run local executable "hudson" with arguments "create . --host localhost --port 3010"
    Then I should see "Ruby/Rails projects without a Gemfile are currently unsupported."

  Scenario: Attempt to create project without scm (hudson create)
    Given I am in the "ruby" project folder
    When I run local executable "hudson" with arguments "create . --host localhost --port 3010"
    Then I should see "Cannot determine project SCM. Currently supported:"

  Scenario: Recreate a job (hudson create --override)
    Given I am in the "ruby" project folder
    When I create a job
    Then I should see "Added ruby project 'ruby' to Hudson."
    When I recreate a job
    Then I should see "Added ruby project 'ruby' to Hudson."

  Scenario: Trigger a job build (hudson build)
    Given I am in the "ruby" project folder
    When I create a job
    When I run local executable "hudson" with arguments "build"
    Then I should see "Build for 'ruby' running now..."
  
  Scenario: Trigger a job build on invaild project (hudson build)
    Given I am in the "ruby" project folder
    When I run local executable "hudson" with arguments "build . --host localhost --port 3010"
    Then I should see "ERROR: No job 'ruby' on server."
  
  Scenario: Remove a job (hudson remove)
    Given I am in the "ruby" project folder
    When I create a job
    Then I should see "Added ruby project 'ruby' to Hudson."
    When I run local executable "hudson" with arguments "remove ."
    Then I should see "Removed project 'ruby' from Hudson."
  
  Scenario: Remove a job that doesn't exist gives error (hudson remove)
    Given I am in the "ruby" project folder
    When I run local executable "hudson" with arguments "remove . --host localhost --port 3010"
    Then I should see "ERROR: Failed to delete project 'ruby'."
  
