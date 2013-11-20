require 'jenkins/plugin/version'
require 'jenkins/plugin/specification'
require 'jenkins/plugin/tools/hpi'
require 'jenkins/plugin/tools/loadpath'

module Jenkins
  # given the IO handle, produce the basic manifest entries that are common between hpi and hpl formats

  def self.spec
    @spec ||= Jenkins::Plugin::Specification.load(Dir['*.pluginspec'].first)
  end

  class Rake
    def self.install_tasks
      self.new.install
    end

    include ::Rake::DSL if defined? ::Rake::DSL

    def install
      desc "Directory used as JENKINS_HOME during 'rake server'"
      directory work = "work"

      desc "remove built artifacts"
      task :clean do
        sh "rm -rf pkg"
        sh "rm -rf vendor"
      end

      desc "output the development servers loadpath"
      task :loadpath do
        loadpath = Jenkins::Plugin::Tools::Loadpath.new(:default)
        puts loadpath.to_path
      end

      desc "package up stuff into HPI file"
      task :package do
        require 'jenkins/plugin/tools/package'
        Jenkins::Plugin::Tools::Package.new(Jenkins.spec,"pkg").build
      end

      desc "run a Jenkins server with this plugin"
      task :server do
        require 'jenkins/plugin/tools/server'

        server = Jenkins::Plugin::Tools::Server.new(Jenkins.spec, "work")
        server.run!
      end
    end
  end
end
