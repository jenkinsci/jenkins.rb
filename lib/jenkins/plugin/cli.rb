
require 'thor'
require 'jenkins/plugin/specification'
require 'jenkins/plugin/cli/formatting'


module Jenkins
  class Plugin
    class CLI < Thor
      extend Formatting

      desc "server", "run a test server with plugin"
      method_option :home, :desc => "set server work directory", :default => 'work'
      method_option :port, :desc => "server http port (currently ignored)", :default => 8080
      def server
        require 'jenkins/plugin/tools/server'
        server = Jenkins::Plugin::Tools::Server.new(spec, options[:home])
        server.run!
      end

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