
#require 'jenkins/plugin/version'

require 'jenkins/plugin/version'

module Jenkins
  class Plugin
    module Tools
      class Manifest

        def initialize(spec)
          @spec = spec
        end

        def write_hpi(io)
          w = Writer.new(io)
          w.put "Manifest-Version", "1.0"
          w.put "Created-By", Jenkins::Plugin::VERSION
          w.put "Build-Ruby-Platform", RUBY_PLATFORM
          w.put "Build-Ruby-Version", RUBY_VERSION

          w.put "Group-Id", "org.jenkins-ci.plugins"
          w.put "Short-Name", @spec.name
          w.put "Long-Name", @spec.name # TODO: better name
          w.put "Url", "http://jenkins-ci.org/" # TODO: better value

          w.put "Plugin-Class", "ruby.RubyPlugin"
          w.put "Plugin-Version", @spec.version
          w.put "Jenkins-Version", "1.426"

          w.put "Plugin-Dependencies", @spec.dependencies.map{|k,v| "#{k}:#{v}"}.join(",")
        end

        def write_hpl(io, loadpath)
          write_hpi(io)

          w = Writer.new(io)
          w.put "Load-Path", loadpath.to_a.join(':')
          w.put "Lib-Path", "#{Dir.pwd}/lib/"
          w.put "Models-Path", "#{Dir.pwd}/models"
          # Stapler expects view erb/haml scripts to be in the JVM ClassPath
          w.put "Class-Path", "#{Dir.pwd}/views" if File.exists?("#{Dir.pwd}/views")
          # Directory for static images, javascript, css, etc. of this plugin.
          # The static resources are mapped under #CONTEXTPATH/plugin/SHORTNAME/
          w.put "Resource-Path", "#{Dir.pwd}/static"
        end

        class Writer

          MAX_LENGTH = 72.to_i

          def initialize(io)
            @io = io
          end

          def put(key, value)
            @io.puts "#{key}: #{manifest_truncate(value)}"
          end

          def manifest_truncate(message)
            if message.length < MAX_LENGTH
              return message
            end

            line = message[0 ... MAX_LENGTH] + "\n"
            offset = MAX_LENGTH

            while offset < message.length
              line += " #{message[offset ... (offset + MAX_LENGTH - 1)]}\n"
              offset += (MAX_LENGTH - 1)
            end
            return line
          end
        end
      end
    end
  end
end
