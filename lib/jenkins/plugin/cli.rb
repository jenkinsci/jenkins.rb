
require 'thor'
require 'jenkins/plugin/specification'
require 'jenkins/plugin/cli/formatting'
require 'jenkins/plugin/cli/new'
require 'jenkins/plugin/cli/generate'


module Jenkins
  class Plugin
    class CLI < Thor
      extend Formatting

      register New, "new", "new NAME", "create a new plugin called NAME"
      register Generate, "generate", "generate [options] [arguments]", "add new classes/templates and views to your project"
      map "g" => "generate"


      desc "build", "build plugin into .hpi file suitable for distribution"
      def build
        shell.say "TODO: build()"
      end

      desc "server", "run a test server with plugin"
      method_option :home, :desc => "set server work directory", :default => 'work'
      method_option :port, :desc => "server http port (currently ignored)", :default => 8080
      method_option :war,  :desc => "specify a custom jenkins.war to run the plugin with"
      def server
        require 'jenkins/plugin/tools/server'
        server = Jenkins::Plugin::Tools::Server.new(spec, options[:home], options[:war])
        server.run!
      end
      map "s" => "server"

      desc "version", "show jpi version information"
      def version
        require 'jenkins/plugin/version'
        shell.say Jenkins::Plugin::VERSION
      end
      map ["-v","--version"] => "version"

      desc "help [COMMAND]", "get help for COMMAND, or for jpi itself"
      def help(command = nil)
        super
      end

      private

      def spec
        Specification.find!
      end

    end
  end
end