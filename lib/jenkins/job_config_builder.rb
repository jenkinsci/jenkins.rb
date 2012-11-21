require "builder"

module Jenkins
  class JobConfigBuilder
    attr_accessor :job_type
    attr_accessor :steps, :rubies
    attr_accessor :scm, :public_scm, :scm_branches, :scm_refspec
    attr_accessor :scm, :public_scm, :git_branches
    attr_accessor :assigned_node, :node_labels # TODO just one of these
    attr_accessor :envfile
    attr_accessor :description
    attr_accessor :sidebar_links
    attr_accessor :child_projects
    attr_accessor :mail_recipients
    attr_accessor :mail_build_breakers
    attr_accessor :triggers
    attr_accessor :join_triggers
    attr_accessor :publish_documents
    attr_accessor :publish_dupe_code_results
    attr_accessor :publish_testing_tools_results
    attr_accessor :junit_test_result_report
    attr_accessor :schedule_failed_builds
    attr_accessor :block_downstream, :block_upstream
    attr_accessor :artifact_archiver
    attr_accessor :fingerprint
    attr_accessor :mail_upstream_committers
    
    InvalidTemplate = Class.new(StandardError)
    
    VALID_JOB_TEMPLATES = %w[none rails rails3 ruby rubygem erlang]
    
    # +job_type+ - template of default steps to create with the job
    # +steps+ - array of [:method, cmd], e.g. [:build_shell_step, "bundle initial"]
    #   - Default is based on +job_type+.
    # +scm+           - URL to the repository. Currently only support git URLs.
    # +public_scm+    - convert the +scm+ URL to a publicly accessible URL for the Jenkins job config.
    # +scm_branches+  - array of branches to run builds. Default: ['master']
    # +rubies+        - list of RVM rubies to run tests (via Jenkins Axes).
    # +assigned_node+ - restrict this job to running on slaves with these labels (space separated)
    def initialize(job_type = :ruby, &block)
      self.job_type = job_type.to_s if job_type
      
      yield self

      self.scm_branches ||= ["master"]
      raise InvalidTemplate unless VALID_JOB_TEMPLATES.include?(job_type.to_s)
    end
  
    def builder
      b = Builder::XmlMarkup.new :indent => 2
      b.instruct!
      b.tag!(matrix_project? ? "matrix-project" : "project") do
        b.actions
        b.description description
        b.keepDependencies false
        #b.properties
        build_properties b
        build_scm b
        b.assignedNode assigned_node if assigned_node
        b.canRoam !assigned_node
        b.disabled false
        build_block_downstream b
        build_block_upstream b
        #b.triggers :class => "vector"
        build_triggers b
        b.concurrentBuild false
        build_axes b if matrix_project?
        build_steps b
        #b.publishers
        build_publishers b
        build_wrappers b
        b.runSequentially false if matrix_project?
      end
    end
  
    def to_xml
      builder.to_s
    end
  
    protected
    
    # <scm class="hudson.plugins.git.GitSCM"> ... </scm>
    def build_scm(b)
      if scm && scm =~ /git/
        scm_url = public_scm ? public_only_git_scm(scm) : scm
        b.scm :class => "hudson.plugins.git.GitSCM" do
          b.configVersion 1
          b.remoteRepositories do
            b.tag! "org.spearce.jgit.transport.RemoteConfig" do
              b.string "origin"
              b.int 5
              b.string "fetch"
              if scm_refspec
                b.string scm_refspec
              else
                b.string "+refs/heads/*:refs/remotes/origin/*"
              end
              b.string "receivepack"
              b.string "git-upload-pack"
              b.string "uploadpack"
              b.string "git-upload-pack"
              b.string "url"
              b.string scm_url
              b.string "tagopt"
              b.string
            end
          end
        
          if scm_branches
            b.branches do
              scm_branches.each do |branch|
                b.tag! "hudson.plugins.git.BranchSpec" do
                  b.name branch
                end
              end
            end
          end
        
          b.localBranch
          b.mergeOptions
          b.recursiveSubmodules false
          b.doGenerateSubmoduleConfigurations false
          b.authorOrCommitter false
          b.clean false
          b.wipeOutWorkspace false
          b.buildChooser :class => "hudson.plugins.git.util.DefaultBuildChooser"
          b.gitTool "Default"
          b.submoduleCfg :class => "list"
          b.relativeTargetDir
          b.excludedRegions
          b.excludedUsers
        end
      end
    end

    def matrix_project?
      !(rubies.blank? && node_labels.blank?)
    end
  
    # <hudson.matrix.TextAxis>
    #   <name>RUBY_VERSION</name>
    #   <values>
    #     <string>1.8.7</string>
    #     <string>1.9.2</string>
    #     <string>rbx-head</string>
    #     <string>jruby</string>
    #   </values>
    # </hudson.matrix.TextAxis>
    # <hudson.matrix.LabelAxis>
    #   <name>label</name>
    #   <values>
    #     <string>1.8.7</string>
    #     <string>ubuntu</string>
    #   </values>
    # </hudson.matrix.LabelAxis>
    def build_axes(b)
      b.axes do
        unless rubies.blank?
          b.tag! "hudson.matrix.TextAxis" do
            b.name "RUBY_VERSION"
            b.values do
              rubies.each do |rvm_name|
                b.string rvm_name
              end
            end
          end
        end
        unless node_labels.blank?
          b.tag! "hudson.matrix.LabelAxis" do
            b.name "label"
            b.values do
              node_labels.each do |label|
                b.string label
              end
            end
          end
        end
      end
    end
    
    def build_properties(b)
      if !sidebar_links
        b.properties
      else
        b.properties do
          b.tag! "hudson.plugins.sidebar__link.ProjectLinks" do
            b.links do
              sidebar_links.each do |link|
                b.tag! "hudson.plugins.sidebar__link.LinkAction" do
                  b.url link[:url]
                  b.text link[:text]
                  b.icon link[:icon]
                end
              end
            end
          end
        end
      end
    end
    
    def build_publishers(b)
      b.publishers do
        if publish_dupe_code_results
          b.tag! "hudson.plugins.dry.DryPublisher" do
            b.threshold
            b.newThreshold
            b.failureThreshold
            b.newFailureThreshold
            b.healthy
            b.unHealthy
            b.pluginName "[DRY]"
            b.thresholdLimit "low"
            b.defaultEncoding
            b.useDeltaValues false
            b.canRunOnFailed false
            b.pattern publish_dupe_code_results[:pattern]
            b.highThreshold publish_dupe_code_results[:high_threshold]
            b.normalThreshold publish_dupe_code_results[:normal_threshold]
          end
        end
        if artifact_archiver
          b.tag! "hudson.tasks.ArtifactArchiver" do
            b.artifacts artifact_archiver[:artifacts]
            if artifact_archiver[:latest_only]
              b.latestOnly artifact_archiver[:latest_only]
            else
              b.latestOnly false
            end
          end
        end
        if child_projects
          b.tag! "hudson.tasks.BuildTrigger" do
            if child_projects.class == String # To accept all the child projects the way they are currently formatted
              b.childProjects child_projects #TODO: allow passing of array or string
              b.threshold do
                b.name "SUCCESS"
                b.ordinal "0"
                b.color "BLUE"
              end
            else # to accept child_projects passed as an array, like ["children", "FAILURE"] to build even if it fails
              children, threshold = child_projects
              b.childProjects children
              b.threshold do
                case threshold
                  when "SUCCESS"
                    b.name "SUCCESS"
                    b.ordinal "0"
                    b.color "BLUE"
                  when "UNSTABLE"
                    b.name "UNSTABLE"
                    b.ordinal "1"
                    b.color "YELLOW"
                  when "FAILURE"
                    b.name "FAILURE"
                    b.ordinal "2"
                    b.color "RED"
                end
              end
            end
          end
        end
        if junit_test_result_report
          b.tag! "hudson.tasks.junit.JUnitResultArchiver" do
            b.testResults junit_test_result_report[:test_report_xmls]
            b.keepLongStdio junit_test_result_report[:retain_stdio] ? true : false
            b.testDataPublishers
          end
        end
        if publish_documents
          b.tag! "hudson.plugins.doclinks.DocLinksPublisher" do
            b.documents do
              if publish_documents.class == Hash # if you pass a hash, it will input only that one document to publish
                b.tag! "hudson.plugins.doclinks.Document" do
                  b.title publish_documents[:title]
                  b.description publish_documents[:description] if publish_documents[:description]
                  b.directory publish_documents[:directory]
                  b.file publish_documents[:file] if publish_documents[:file]
                  b.id 1
                end
              else # Array of hashes
                publish_documents.each_with_index do |doc, index| # if you pass an array, it will publish all the docs passed in the array
                  b.tag! "hudson.plugins.doclinks.Document" do
                    b.title doc[:title]
                    b.description doc[:description] if doc[:description]
                    b.directory doc[:directory]
                    b.file doc[:file] if doc[:file]
                    b.id index + 1
                  end
                end
              end
            end
          end
        end
        if publish_testing_tools_results
          b.tag! "com.thalesgroup.hudson.plugins.xunit.XUnitPublisher" do
            b.types do
              b.tag! "com.thalesgroup.dtkit.metrics.hudson.model.PHPUnitJunitHudsonTestType" do
                b.pattern publish_testing_tools_results[:pattern]
                b.faildedIfNotNew publish_testing_tools_results[:fail_no_results]
                b.deleteOutputFiles publish_testing_tools_results[:del_tmp_junit]
                b.stopProcessingIfError publish_testing_tools_results[:fail_on_result_error]
              end
            end
          end
        end
        if join_triggers && !matrix_project? #TODO: error message if its a matrix project?
          b.tag! "join.JoinTrigger" do
            #join_triggers.each do |project|
            b.joinProjects join_triggers #TODO: allow passing of array or string
            b.joinPublishers
            b.evenIfDownstreamUnstable false
          end
        end
        if mail_recipients
          b.tag! "hudson.tasks.Mailer" do
            b.recipients mail_recipients
            b.dontNotifyEveryUnstableBuild false
            b.sendToIndividuals mail_build_breakers ? true : false
          end
        end
        if mail_upstream_committers
          b.tag! "hudson.plugins.blame__upstream__commiters.BlameUpstreamCommitersPublisher" do
            b.sendToIndividuals false
          end
        end
        if schedule_failed_builds
          interval, retries = schedule_failed_builds
          b.tag! "com.progress.hudson.ScheduleFailedBuildsPublisher" do
            b.interval interval
            b.maxRetries retries
          end
        end
      end
    end
    
    # Example:
    # <buildWrappers>
    #   <hudson.plugins.envfile.EnvFileBuildWrapper>
    #     <filePath>/path/to/env/file</filePath>
    #   </hudson.plugins.envfile.EnvFileBuildWrapper>
    # </buildWrappers>
    def build_wrappers(b)
      if envfile
        b.buildWrappers do
          self.envfile = [envfile] unless envfile.is_a?(Array)
          b.tag! "hudson.plugins.envfile.EnvFileBuildWrapper" do
            envfile.each do |file|
              b.filePath file
            end
          end
        end
      else
        b.buildWrappers
      end
    end
    
    # If :build_block_downstream is set to true, this sets it to true for the job,
    # otherwise it will be set to false.
    def build_block_downstream(b)
      if block_downstream
        b.blockBuildWhenDownstreamBuilding true
      else
        b.blockBuildWhenDownstreamBuilding false
      end
    end
    
    # If :build_block_downstream is set to true, this sets it to true for the job,
    # otherwise it will be set to false.
    def build_block_upstream(b)
      if block_upstream
        b.blockBuildWhenUpstreamBuilding true
      else
        b.blockBuildWhenUpstreamBuilding false
      end
    end
    
    # Pass in an array of arrays of the trigger type, and the poll interval.
    # e.g. triggers = [ [:build_periodically, "0 18 * * *"], [:poll_scm, "0 0 * * *"] ]
    # this would set the job to periodically build at 6PM everyday, and poll scm for build at Midnight, everyday
    def build_triggers(b)
      b.triggers :class => "vector" do
        if schedule_failed_builds # putting it in build triggers if we're scheduling failed builds
          triggers = [] if !triggers #declaring triggers to be an array if it doesn't exist
          triggers << ["schedule_failed_builds_trigger", "* * * * *"]
        end
        if triggers
          triggers.each do |trigger|
            method, cmd = trigger
            send(method.to_sym, b, cmd) # e.g. poll_scm(b, "0 18 * * *")
          end
        end
      end
    end
    
    def poll_scm(b, command)
      b.tag! "hudson.triggers.SCMTrigger" do
        b.spec do
          b << command.to_xs
        end
      end
    end
    
    def build_periodically(b, command)
      b.tag! "hudson.triggers.TimerTrigger" do
        b.spec do
          b << command.to_xs
        end
      end
    end
    
    def schedule_failed_builds_trigger(b, command)
      b.tag! "com.progress.hudson.ScheduleFailedBuildsTrigger" do
        b.spec do
          b << command.to_xs
        end
      end
    end
    
    # The important sequence of steps that are run to process a job build.
    # Can be defaulted by the +job_type+ using +default_steps(job_type)+,
    # or customized via +steps+ array.
    def build_steps(b)
      if !steps
        b.builders
      else
        b.builders do
          self.steps ||= default_steps(job_type)
          steps.each do |step|
            method, cmd = step
            send(method.to_sym, b, cmd) # e.g. build_shell_step(b, "bundle install")
          end
          if fingerprint
            b.tag! "hudson.plugins.createfingerprint.CreateFingerprint" do
              b.targets do
                b << fingerprint
              end
            end
          end
        end
      end
    end
    
    def default_steps(job_type)
      steps = case job_type.to_sym
      when :rails, :rails3
        [
          [:build_shell_step, "bundle install"],
          [:build_ruby_step, <<-RUBY.gsub(/^            /, '')],
            unless File.exist?("config/database.yml")
              require 'fileutils'
              example = Dir["config/database*"].first
              puts "Using \#{example} for config/database.yml"
              FileUtils.cp example, "config/database.yml"
            end
            RUBY
          [:build_shell_step, "bundle exec rake db:create:all"],
          [:build_shell_step, <<-RUBY.gsub(/^            /, '')],
            if [ -f db/schema.rb ]; then
              bundle exec rake db:schema:load
            else
              bundle exec rake db:migrate
            fi
            RUBY
          [:build_shell_step, "bundle exec rake"]
        ]
      when :ruby, :rubygems
        [
          [:build_shell_step, "bundle install"],
          [:build_shell_step, "bundle exec rake"]
        ]
      when :erlang
        [
          [:build_shell_step, "rebar compile"],
          [:build_shell_step, "rebar ct"]
        ]
      else
        [ [:build_shell_step, 'echo "THERE ARE NO STEPS! Except this one..."'] ]
      end
      rubies.blank? ? steps : default_rvm_steps + steps
    end
    
    def default_rvm_steps
      [
        [:build_shell_step, "rvm $RUBY_VERSION"],
        [:build_shell_step, "rvm gemset create ruby-$RUBY_VERSION && rvm gemset use ruby-$RUBY_VERSION"]
      ]
    end
    
    # <hudson.tasks.Shell>
    #   <command>echo &apos;THERE ARE NO STEPS! Except this one...&apos;</command>
    # </hudson.tasks.Shell>
    def build_shell_step(b, command)
      b.tag! "hudson.tasks.Shell" do
        b.command command.to_xs.gsub("&amp;", '&').gsub("&gt;", '>') #.gsub(%r{"}, '&quot;').gsub(%r{'}, '&apos;')
      end
    end
    
    # <hudson.tasks.BatchFile>
    #   <command>echo &apos;THERE ARE NO STEPS! Except this one...&apos;</command>
    # </hudson.tasks.BatchFile>
    def build_bat_step(b, command)
      b.tag! "hudson.tasks.BatchFile" do
        b.command command.to_xs.gsub("&amp;", '&').gsub("&gt;", '>')
      end
    end
    
    # <hudson.tasks.Ant>
    def build_ant_step(b, targets)
      b.tag! "hudson.tasks.Ant" do
        b.targets targets
        b.buildFile "../build.xml"
      end
    end
    
    # <hudson.tasks.XShell>
    def build_xshell_step(b, command)
      b.tag! "hudson.plugins.xshell.XShellBuilder" do
        b.commandLine command
        b.executeFromWorkingDir false
      end
    end

    # <hudson.plugins.ruby.Ruby>
    #   <command>unless File.exist?(&quot;config/database.yml&quot;)
    #   require &apos;fileutils&apos;
    #   example = Dir[&quot;config/database*&quot;].first
    #   puts &quot;Using #{example} for config/database.yml&quot;
    #   FileUtils.cp example, &quot;config/database.yml&quot;
    # end</command>
    # </hudson.plugins.ruby.Ruby>
    def build_ruby_step(b, command)
      b.tag! "hudson.plugins.ruby.Ruby" do
        b.command do
          b << command.to_xs.gsub(%r{"}, '&quot;').gsub(%r{'}, '&apos;')
        end
      end
    end
  
    # Usage: build_ruby_step b, "db:schema:load"
    #
    # <hudson.plugins.rake.Rake>
    #   <rakeInstallation>(Default)</rakeInstallation>
    #   <rakeFile></rakeFile>
    #   <rakeLibDir></rakeLibDir>
    #   <rakeWorkingDir></rakeWorkingDir>
    #   <tasks>db:schema:load</tasks>
    #   <silent>false</silent>
    # </hudson.plugins.rake.Rake>
    def build_rake_step(b, tasks)
      b.tag! "hudson.plugins.rake.Rake" do
        b.rakeInstallation "(Default)"
        b.rakeFile
        b.rakeLibDir
        b.rakeWorkingDir
        b.tasks tasks
        b.silent false
      end
    end
    
    # Converts git@github.com:drnic/newgem.git into git://github.com/drnic/newgem.git
    def public_only_git_scm(scm_url)
      if scm_url =~ /git@([\w\-_.]+):(.+)\.git/
        "git://#{$1}/#{$2}.git"
      else
        scm_url
      end
    end
  end
end