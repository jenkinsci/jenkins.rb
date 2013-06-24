
require 'thor'
require 'jenkins/plugin/specification'
require 'jenkins/plugin/cli/formatting'
require 'jenkins/plugin/cli/new'
require 'jenkins/plugin/cli/generate'

# Until a new version (>= 0.14.6 & 0.15.0rc2) is released, this backports a fix
# for JRuby argument handling:
# https://github.com/wycats/thor/commit/33490a59ed297eb798381f1c86cbaa3608413eaf
class Thor
  class Task
    def sans_backtrace(backtrace, caller) #:nodoc:
      saned  = backtrace.reject { |frame| frame =~ FILE_REGEXP || (frame =~ /\.java:/ && RUBY_PLATFORM =~ /java/) }
      saned -= caller
    end
  end
end


module Jenkins
  class Plugin
    class CLI < Thor
      extend Formatting

      register New, "new", "new NAME", "create a new plugin called NAME"
      register Generate, "generate", "generate [options] [arguments]", "add new classes/templates and views to your project"
      map "g" => "generate"


      desc "build", "build plugin into .hpi file suitable for distribution"
      def build
        require 'jenkins/plugin/tools/package'
        pkg = Tools::Package.new(spec, "pkg")
        pkg.build
        pkg
      end

      desc "server", "run a test server with plugin"
      method_option :home, :desc => "set server work directory", :default => 'work'
      method_option :port, :desc => "server http port", :default => 8080
      method_option :war,  :desc => "specify a custom jenkins.war to run the plugin with"
      def server
        require 'jenkins/plugin/tools/server'
        server = Tools::Server.new(spec, options[:home], options[:war], options[:port])
        server.run!
      end
      map "s" => "server"

      desc "release", "release to jenkins-ci.org"
      method_option :release, :desc => "deploy as a release (as opposed to a snapshot)", :type => :boolean
      def release
        require 'jenkins/plugin/tools/release'

        Tools::Release.new(spec,build().file_name, !options[:release]).run
      end

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
