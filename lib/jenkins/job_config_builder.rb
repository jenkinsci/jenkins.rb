require "builder"

module Jenkins
  class JobConfigBuilder
    attr_accessor :job_type
    attr_accessor :steps, :rubies
    attr_accessor :triggers
    attr_accessor :publishers
    attr_accessor :log_rotate
    attr_accessor :scm, :public_scm, :scm_branches
    attr_accessor :assigned_node, :node_labels # TODO just one of these
    attr_accessor :envfile
    
    InvalidTemplate = Class.new(StandardError)
    
    VALID_JOB_TEMPLATES = %w[none rails rails3 ruby rubygem erlang]
    JOB_TRIGGER_THRESHOLDS = {
      "SUCCESS"  => {:ordinal => 0, :color => "BLUE"},
      "UNSTABLE" => {:ordinal => 1, :color => "YELLOW"},
      "FAILURE"  => {:ordinal => 2, :color => "RED"}
    }
    
    # +job_type+ - template of default steps to create with the job
    # +steps+ - array of [:method, cmd], e.g. [:build_shell_step, "bundle initial"]
    #   - Default is based on +job_type+.
    # +scm+           - URL to the repository. Currently only support git URLs.
    # +public_scm+    - convert the +scm+ URL to a publicly accessible URL for the Jenkins job config.
    # +scm_branches+  - array of branches to run builds. Default: ['master']
    # +rubies+        - list of RVM rubies to run tests (via Jenkins Axes).
    # +triggers+      - list of triggers to start the build. Currently only support time triggers
    # +assigned_node+ - restrict this job to running on slaves with these labels (space separated)
    # +publishers+    - define publishers to be performed after a build
    # +log_rotate+    - define log rotation
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
        b.description
        build_log_rotator b
        b.keepDependencies false
        b.properties
        build_scm b
        b.assignedNode assigned_node if assigned_node
        b.canRoam !assigned_node
        b.disabled false
        b.blockBuildWhenUpstreamBuilding false
        build_triggers b
        b.concurrentBuild false
        build_axes b if matrix_project?
        build_steps b
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
              b.string "+refs/heads/*:refs/remotes/origin/*"
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

    # Example
    # <triggers class="vector">
    #   <hudson.triggers.TimerTrigger>
    #     <spec>* * * * *</spec>
    #   </hudson.triggers.TimerTrigger>
    # </triggers>
    def build_triggers(b)
      if triggers
        b.triggers :class => "vector" do
          triggers.each do |trigger|
            case trigger[:class]
            when :timer
              b.tag! "hudson.triggers.TimerTrigger" do
                b.spec trigger[:spec]
              end
            end
          end
        end
      else
        b.triggers :class => "vector"
      end
    end

    # Example
    # <logRotator>
    #   <daysToKeep>14</daysToKeep>
    #   <numToKeep>-1</numToKeep>
    #   <artifactDaysToKeep>-1</artifactDaysToKeep>
    #   <artifactNumToKeep>-1</artifactNumToKeep>
    # </logRotator>
    def build_log_rotator(b)
      if log_rotate
        b.logRotator do
          b.daysToKeep         log_rotate[:days_to_keep] || -1
          b.numToKeep          log_rotate[:num_to_keep] || -1
          b.artifactDaysToKeep log_rotate[:artifact_days_to_keep] || -1
          b.artifactNumToKeep  log_rotate[:artifact_num_to_keep] || -1
        end
      end
    end

    # Example
    # <publishers>
    #   <hudson.plugins.chucknorris.CordellWalkerRecorder>
    #     <factGenerator/>
    #   </hudson.plugins.chucknorris.CordellWalkerRecorder>
    #   <hudson.tasks.BuildTrigger>
    #     <childProjects>Dependent Job, Even more dependent job</childProjects>
    #     <threshold>
    #       <name>SUCCESS</name>
    #       <ordinal>0</ordinal>
    #       <color>BLUE</color>
    #     </threshold>
    #   </hudson.tasks.BuildTrigger>
    #   <hudson.tasks.Mailer>
    #     <recipients>some.guy@example.com, another.guy@example.com</recipients>
    #     <dontNotifyEveryUnstableBuild>false</dontNotifyEveryUnstableBuild>
    #     <sendToIndividuals>true</sendToIndividuals>
    #   </hudson.tasks.Mailer>
    # </publishers>
    def build_publishers(b)
      if publishers
        b.publishers do
          publishers.each do |publisher|
            publisher_name, params = publisher.to_a.first
            case publisher_name
            when :mailer
              b.tag! "hudson.tasks.Mailer" do
                b.recipients params.join(', ')
                b.dontNotifyEveryUnstableBuild false
                b.sendToIndividuals true
              end
            when :job_triggers
              b.tag! "hudson.tasks.BuildTrigger" do
                b.childProjects params[:projects].join(', ')
                b.threshold do
                  trigger_event = params[:on] || "SUCCESS"
                  b.name trigger_event
                  b.ordinal JOB_TRIGGER_THRESHOLDS[trigger_event][:ordinal]
                  b.color JOB_TRIGGER_THRESHOLDS[trigger_event][:color]
                end
              end
            when :chuck_norris
              b.tag! "hudson.plugins.chucknorris.CordellWalkerRecorder" do
                b.factGenerator
              end
            end
          end
        end
      else
        b.publishers
      end
    end
    
    # The important sequence of steps that are run to process a job build.
    # Can be defaulted by the +job_type+ using +default_steps(job_type)+,
    # or customized via +steps+ array.
    def build_steps(b)
      b.builders do
        self.steps ||= default_steps(job_type)
        steps.each do |step|
          method, cmd = step
          send(method.to_sym, b, cmd) # e.g. build_shell_step(b, "bundle install")
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
        b.command command.to_xs.gsub("&amp;", '&') #.gsub(%r{"}, '&quot;').gsub(%r{'}, '&apos;')
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
