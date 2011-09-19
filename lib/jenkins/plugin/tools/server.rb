require 'jenkins/plugin/tools/loadpath'
require 'jenkins/plugin/tools/resolver'
require 'jenkins/plugin/tools/manifest'
require 'jenkins/war'
require 'fileutils'

module Jenkins
  class Plugin
    module Tools
      class Server

        def initialize(spec, workdir)
          @spec = spec
          @workdir = workdir
          @plugindir = "#{workdir}/plugins"
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


          # execute Jenkins
          args = []
          args << "java"
          args << "-Xrunjdwp:transport=dt_socket,server=y,address=8000,suspend=n"
          args << "-DJENKINS_HOME=#{@workdir}"
          args << "-Dstapler.trace=true"
          args << "-Ddebug.YUI=true"
          args << "-jar"
          args << Jenkins::War::LOCATION
          exec *args
        end
      end
    end
  end
end