require "builder"

module Hudson
  class JobConfigBuilder
    attr_accessor :job_type, :matrix_project
    attr_accessor :steps
    attr_accessor :scm, :public_scm, :git_branches, :git_tool
    attr_accessor :assigned_node
    
    InvalidTemplate = Class.new(StandardError)
    
    # +job_type+ - template of default steps to create with the job
    # +steps+ - array of [:method, cmd], e.g. [:build_shell_step, "bundle initial"]
    #   - Default is based on +job_type+.
    # +scm+           - URL to the repository. Currently only support git URLs.
    # +public_scm+    - convert the +scm+ URL to a publicly accessible URL for the Hudson job config.
    # +git_branches+  - array of branches to run builds. Default: ['master']
    # +git_tool+      - key reference for Hudson CI git command. Default: 'Default'
    # +assigned_node+ - restrict this job to running on slaves with these labels (space separated)
    def initialize(job_type = :ruby, &block)
      self.job_type = job_type.to_s if job_type
      
      yield self

      self.git_branches ||= ["master"]
    end
  
    def builder
      b = Builder::XmlMarkup.new :indent => 2
      b.instruct!
      b.tag!(matrix_project? ? "matrix-project" : "project") do
        b.actions
        b.description
        b.keepDependencies false
        b.properties
        build_scm b
        b.assignedNode assigned_node if assigned_node
        b.canRoam !assigned_node
        b.disabled false
        b.blockBuildWhenUpstreamBuilding false
        # build_triggers b
        b.concurrentBuild false
        build_axes b if matrix_project?
        build_steps b
        b.publishers
        b.buildWrappers
        b.runSequentially false if matrix_project?
      end
    end
  
    def to_xml
      builder.to_s
    end
  
    protected
    
    def matrix_project?
      matrix_project ||
        %w[rubygem].include?(job_type)
    end
  
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
        
          if git_branches
            b.branches do
              git_branches.each do |branch|
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
          b.gitTool git_tool ? git_tool : "Default"
          b.submoduleCfg :class => "list"
          b.relativeTargetDir
          b.excludedRegions
          b.excludedUsers
        end
      end
    end
  
    #   <triggers class="vector">
    #     <hudson.triggers.SCMTrigger>
    #       <spec># every minute
    #         * * * * *</spec>
    #     </hudson.triggers.SCMTrigger>
    #   </triggers>
    def build_triggers(b)
      b.triggers :class => "vector" do
        b.tag! "hudson.triggers.SCMTrigger" do
          b.spec "# every minute\n* * * * *"
        end
      end
    end

    # TODO
    def build_axes(b)
      b.axes
    end
    
    # TODO modularise this
    # TODO how to customize? e.g. EngineYard template?
    VALID_JOB_TEMPLATES = %w[rails rails3 ruby rubygem]
    def build_steps(b)
      b.builders do
        if job_type
          raise InvalidTemplate unless VALID_JOB_TEMPLATES.include?(job_type)
          if job_type == "rails" || job_type == "rails3"
            build_shell_step b, "bundle install"
            build_ruby_step b, <<-RUBY.gsub(/^            /, '')
            unless File.exist?("config/database.yml")
              require 'fileutils'
              example = Dir["config/database*"].first
              puts "Using \#{example} for config/database.yml"
              FileUtils.cp example, "config/database.yml"
            end
            RUBY
            build_shell_step b, "bundle exec rake db:schema:load"
            build_shell_step b, "bundle exec rake"
          else
            build_shell_step b, "bundle install"
            build_shell_step b, "bundle exec rake"
          end
        else
          steps.each do |step|
            method, cmd = step
            send(method.to_sym, b, cmd)
          end
        end
      end
    end
  
    # <hudson.tasks.Shell>
    #   <command>bundle install</command>
    # </hudson.tasks.Shell>
    def build_shell_step(b, command)
      b.tag! "hudson.tasks.Shell" do
        b.command command.to_xs.gsub(%r{"}, '&quot;').gsub(%r{'}, '&apos;')
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