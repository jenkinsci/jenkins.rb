require 'jenkins/plugin/tools/loadpath'
require 'jenkins/plugin/tools/resolver'
require 'jenkins/plugin/tools/manifest'
require 'jenkins/war'
require 'fileutils'

module Jenkins
  class Plugin
    module Tools
      class Server

        def initialize(spec, workdir, war = nil, port)
          @spec = spec
          @workdir = workdir
          @plugindir = "#{workdir}/plugins"
          @war = war || Jenkins::War::LOCATION
          @port = port
        end

        def run!
          FileUtils.mkdir_p(@plugindir)
          loadpath = Jenkins::Plugin::Tools::Loadpath.new
          manifest = Jenkins::Plugin::Tools::Manifest.new(@spec)
          resolver = Jenkins::Plugin::Tools::Resolver.new(@spec, @plugindir)

          resolver.resolve!
          # generate the plugin manifest

          File.open("#{@plugindir}/#{@spec.name}.hpl",mode="w+") do |f|
            manifest.write_hpl(f, loadpath)
          end

          # cancel out the effect of being invoked from Bundler
          # otherwise this will affect Bundler that we run from inside Jenkins run by "jpi server"
          ENV['BUNDLE_GEMFILE'] = nil
          ENV['BUNDLE_BIN_PATH'] = nil
          ENV['RUBYOPT'] = nil

          # execute Jenkins
          args = []
          args << "java"
          args << "-Xrunjdwp:transport=dt_socket,server=y,address=8000,suspend=n"
          args << "-DJENKINS_HOME=#{@workdir}"
          args << "-Dstapler.trace=true"
          args << "-Djenkins.development-mode=true"
          args << "-Ddebug.YUI=true"
#          args << "-Djruby.debug.loadService=true"
#          args << "-Djruby.debug.loadService.timing=true"
          args << ENV['JAVA_OPTS'] if ENV.key? 'JAVA_OPTS'
          args << "-jar"
          args << @war
          args << ENV['JENKINS_OPTS'] if ENV.key? 'JENKINS_OPTS'
          unless ENV.key?('JENKINS_OPTS') && !ENV['JENKINS_OPTS'].index("--httpPort=").nil?
            args << "--httpPort=#{@port}"
          end
          exec args.join(' ')
        end
      end
    end
  end
end
