
require 'thor'
require 'jenkins/plugin/cli/formatting'

module Jenkins
  class Plugin
    class CLI < Thor
      extend Formatting

      desc "help [COMMAND]", "get help for COMMAND, or for jpi itself"
      def help(command = nil)
        super
      end

    end
  end
end