require "builder"

module Hudson
  class JobConfigBuilder
    attr_accessor :scm, :git_branches
    attr_accessor :job_type, :matrix_project
    attr_accessor :assigned_node
  
    def initialize(options = nil, &block)
      if options.is_a?(Symbol)
        @job_type = options.to_s
      elsif options.is_a?(Hash)
        @job_type = options[:job_type].to_s
      end
      @matrix_project = %w[rubygem].include? job_type
      yield self
      @git_branches ||= ["**"]
    end
  
    def builder
      b = Builder::XmlMarkup.new :indent => 2
      b.instruct!
      b.tag!(matrix_project ? "matrix-project" : "project") do
        b.actions
        b.description
        b.keepDependencies false
        b.properties
        build_scm b
        b.assignedNode assigned_node if assigned_node
        b.canRoam true
        b.disabled false
        b.blockBuildWhenUpstreamBuilding false
        build_triggers b
        b.concurrentBuild false
        build_axes b if matrix_project
        build_steps b
        b.publishers
        b.buildWrappers
        b.runSequentially false if matrix_project
      end
    end
  
    def to_xml
      builder.to_s
    end
  
    protected
  
    # <scm class="hudson.plugins.git.GitSCM"> ... </scm>
    def build_scm(b)
      if scm && scm =~ /git/
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
              b.string scm
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
        
          b.mergeOptions
          b.doGenerateSubmoduleConfigurations false
          b.clean false
          b.choosingStrategy "Default"
          b.submoduleCfg :class => "list"
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
  
    def build_axes(b)
      b.axes
    end
  
    def build_steps(b)
      b.builders do
        if job_type == "rails"
          build_ruby_step b, <<-RUBY.gsub(/^      /, '')
          unless File.exist?("config/database.yml")
            require 'fileutils'
            example = Dir["config/database*"].first
            puts "Using \#{example} for config/database.yml"
            FileUtils.cp example, "config/database.yml"
          end
          RUBY
          build_rake_step b, "db:schema:load"
          build_rake_step b, "features"
          build_rake_step b, "spec"
        elsif job_type == "rubygem"
          build_rake_step b, "features"
        end
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
        b.command command
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
  end
end