require 'jenkins/plugin/version'
require 'jenkins/plugin/tools/hpi'
require 'jenkins/plugin/tools/loadpath'
require 'zip/zip'

module Jenkins
  # given the IO handle, produce the basic manifest entries that are common between hpi and hpl formats
  def self.generate_manifest(f)
    f.puts "Manifest-Version: 1.0"
    f.puts "Created-By: #{Jenkins::Plugin::VERSION}"
    f.puts "Build-Ruby-Platform: #{RUBY_PLATFORM}"
    f.puts "Build-Ruby-Version: #{RUBY_VERSION}"

    f.puts "Group-Id: org.jenkins-ci.plugins"
    f.puts "Short-Name: #{::PluginName}"
    f.puts "Long-Name: #{::PluginName}" # TODO: better name
    f.puts "Url: http://jenkins-ci.org/" # TODO: better value
    # f.puts "Compatible-Since-Version:"
    f.puts "Plugin-Class: ruby.RubyPlugin"
    f.puts "Plugin-Version: #{::PluginVersion}"
    f.puts "Jenkins-Version: 1.426"

    f.puts "Plugin-Dependencies: " + ::PluginDeps.map{|k,v| "#{k}:#{v}"}.join(",")
    # f.puts "Plugin-Developers:"
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

      # verify that necessary metadata constants are defined
      task :verify_constants do
        ["PluginName","PluginVersion"].each do |n|
          fail("Constant #{n} is not defined") unless Object.const_defined?(n)
        end
      end

      desc "output the development servers loadpath"
      task :loadpath do
        loadpath = Jenkins::Plugin::Tools::Loadpath.new(:default)
        puts loadpath.to_path
      end

      directory target = "pkg"
      desc "bundle gems"
      task :bundle => [target] do
        require 'java'
        require 'bundler'
        require 'bundler/cli'

        puts "bundling..."
        ENV['BUNDLE_APP_CONFIG'] = "#{target}/vendor/bundle"
        Bundler::CLI.start ["--standalone", "--path", "#{target}/vendor/gems", "--without", "development"]
      end

      desc "package up stuff into HPI file"
      task :package => [:verify_constants, target, :bundle] do

        file_name = "#{target}/#{::PluginName}.hpi"
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
        puts "#{::PluginName} plugin #{::PluginVersion} built to #{file_name}"
      end

      desc "resolve dependency plugins into #{work}/plugins"
      task :'resolve-dependency-plugins' => [work] do
        FileUtils.mkdir_p("#{work}/plugins")

        puts "Copying plugin dependencies into #{work}/plugins"
        ::PluginDeps.each do |short_name,version|
          FileUtils.cp Jenkins::Plugin::Tools::Hpi::resolve(short_name,version), "#{work}/plugins/#{short_name}.hpi", :verbose=>true
        end
      end

      desc "run a Jenkins server with this plugin"
      task :server => :'resolve-dependency-plugins' do
        require 'jenkins/war'
        require 'zip/zip'
        require 'fileutils'

        loadpath = Jenkins::Plugin::Tools::Loadpath.new

        # generate the plugin manifest
        FileUtils.mkdir_p("#{work}/plugins")
        File.open("#{work}/plugins/#{::PluginName}.hpl",mode="w+") do |f|
          Jenkins.generate_manifest f

          # f.puts "Libraries: "+["lib","models","pkg/vendor"].collect{|r| Dir.pwd+'/'+r}.join(",")
          # TODO: where do we put views?
          # TODO: where do we put static resources?
          f.puts "Load-Path: #{loadpath.to_path}"
          f.puts "Resource-Path: #{Dir.pwd}/views"
          f.puts "Lib-Path: #{Dir.pwd}/lib/"
          f.puts "Models-Path: #{Dir.pwd}/models"
        end

        # TODO: assemble dependency plugins

        # execute Jenkins
        args = []
        args << "java"
        args << "-Xrunjdwp:transport=dt_socket,server=y,address=8000,suspend=n"
        args << "-DJENKINS_HOME=#{work}"
        args << "-jar"
        args << Jenkins::War::LOCATION
        exec *args
      end

    end
  end
end
