require 'jenkins/plugin/version'
require 'jenkins/plugin/specification'
require 'jenkins/plugin/tools/hpi'
require 'jenkins/plugin/tools/loadpath'
require 'zip/zip'

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

      directory target = "pkg"
      desc "bundle gems"
      task :bundle => [target] do
        fail "we still need to backport some features from bundler 1.1 prereleases for this feature to work"
        require 'java'
        require 'bundler'
        require 'bundler/cli'

        puts "bundling..."
        ENV['BUNDLE_APP_CONFIG'] = "#{target}/vendor/bundle"
        Bundler::CLI.start ["--standalone", "--path", "#{target}/vendor/gems", "--without", "development"]
      end

      desc "package up stuff into HPI file"
      task :package => [:verify_constants, target, :bundle] do

        file_name = "#{target}/#{Jenkins.spec.name}.hpi"
        File.delete file_name if File.exists?(file_name)

        Zip::ZipFile.open(file_name, Zip::ZipFile::CREATE) do |zipfile|
          zipfile.get_output_stream("META-INF/MANIFEST.MF") do |f|
            Jenkins.generate_manifest(f)
            f.puts "Bundle-Path: vendor/gems"
          end
          zipfile.mkdir("WEB-INF/classes")

          ["lib","models","views", "#{target}/vendor"].each do |d|
            Dir.glob("#{d}/**/*") do |f|
              if !File.directory? f
                zipfile.add("WEB-INF/classes/#{f.gsub("#{target}/",'')}",f)
              end
            end
          end
        end
        puts "#{Jenkins.spec.name} plugin #{Jenkins.spec.version} built to #{file_name}"
      end

      desc "run a Jenkins server with this plugin"
      task :server do
        require 'jenkins/plugin/tools/resolver'
        require 'jenkins/plugin/tools/manifest'

        require 'jenkins/war'
        require 'zip/zip'
        require 'fileutils'

        loadpath = Jenkins::Plugin::Tools::Loadpath.new
        manifest = Jenkins::Plugin::Tools::Manifest.new(Jenkins.spec)
        resolver = Jenkins::Plugin::Tools::Resolver.new(Jenkins.spec, "#{work}/plugins")

        resolver.resolve!
        # generate the plugin manifest
        FileUtils.mkdir_p("#{work}/plugins")
        File.open("#{work}/plugins/#{Jenkins.spec.name}.hpl",mode="w+") do |f|
          manifest.write_hpl(f, loadpath)
        end


        # execute Jenkins
        args = []
        args << "java"
        args << "-Xrunjdwp:transport=dt_socket,server=y,address=8000,suspend=n"
        args << "-DJENKINS_HOME=#{work}"
        args << "-Dstapler.trace=true"
        args << "-Ddebug.YUI=true"
        args << "-jar"
        args << Jenkins::War::LOCATION
        exec *args
      end

    end
  end
end
