require 'jenkins/plugin/tools/version'
require 'zip/zip'

module Jenkins
  class Rake
    def self.install_tasks
      self.new.install
    end

    include ::Rake::DSL if defined? ::Rake::DSL

    def install

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

      directory target = "pkg"
      desc "bundle gems"
      task :bundle => [target] do
        require 'java'
        puts "bundling..."
        ENV['BUNDLE_APP_CONFIG'] = "#{target}/vendor/bundle"
        sh "bundle install --standalone --path #{target}/vendor/gems --without development"
      end

      desc "package up stuff into HPI file"
      task :package => [:verify_constants, target, :bundle] do

        file_name = "#{target}/#{::PluginName}.hpi"
        File.delete file_name if File.exists?(file_name)

        Zip::ZipFile.open(file_name, Zip::ZipFile::CREATE) do |zipfile|
          zipfile.get_output_stream("META-INF/MANIFEST.MF") do |f|
            f.puts "Manifest-Version: 1.0"
            f.puts "Created-By: #{Jenkins::Plugin::Tools::VERSION}"
            f.puts "Build-Ruby-Platform: #{RUBY_PLATFORM}"
            f.puts "Build-Ruby-Version: #{RUBY_VERSION}"

            f.puts "Group-Id: org.jenkins-ci.plugins"
            f.puts "Short-Name: #{::PluginName}"
            f.puts "Long-Name: #{::PluginName}"     # TODO: better name
            f.puts "Url: http://jenkins-ci.org/"    # TODO: better value
            # f.puts "Compatible-Since-Version:"
            f.puts "Plugin-Class: ruby.RubyPlugin"
            f.puts "Plugin-Version: #{::PluginVersion}"
            f.puts "Jenkins-Version: 1.426"
            f.puts "Plugin-Dependencies: ruby-runtime:0.1-SNAPSHOT"
            # f.puts "Plugin-Developers:"
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
    end
  end
end
