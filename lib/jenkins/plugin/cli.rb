
require 'thor'
require 'jenkins/plugin/specification'
require 'jenkins/plugin/cli/formatting'


module Jenkins
  class Plugin
    class CLI < Thor
      extend Formatting

      desc "server", "load jenkins plugin in a test server"
      method_option :home, :desc => "directory to use as "
      def server
        require 'jenkins/plugin/tools/server'
        server = Jenkins::Plugin::Tools::Server.new(spec, "work")
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