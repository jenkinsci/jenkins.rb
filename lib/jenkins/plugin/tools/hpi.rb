require 'zip/zip'
require 'net/http'
require 'uri'
require 'fileutils'

module Jenkins
  class Plugin
    module Tools
      # class for parsing hpi file and its manifests
      class Hpi
        attr_reader :file, :manifest

        # take the path name to the plugin file
        def initialize(file)
          @file = file

          # load and parse manifests
          Zip::ZipFile.open(@file) do |zip|
            zip.get_input_stream("META-INF/MANIFEST.MF") do |m|
              # main section of the manifest
              @manifest = parse_manifest(m.read)[0]
            end
          end

          # parse dependencies into hash
          @dependencies = {}
          deps = @manifest["Plugin-Dependencies"]
          if deps
            deps.split(",").each do |token|
              token = token.gsub(/;.+/,"")  # trim off the optional portions
              name,ver = token.split(":")
              @dependencies[name] = ver
            end
          end
        end

        # given the plugin short name and the version number,
        # return the path name of the .hpi file by either locating the plugin locally or downloading it.
        def self.resolve(short_name,version)
          # this is where we expect the retrieved file to be
          cache = File.expand_path "~/.jenkins/cache/plugins/#{short_name}/#{version}/#{short_name}.hpi"

          return cache if File.exists?(cache)

          # now we start looking for places to find them

          # is it in the local maven2 repository?
          maven = File.expand_path "~/.m2/repository/org/jenkins-ci/plugins/#{short_name}/#{version}/#{short_name}-#{version}.hpi"
          return maven if File.exists?(maven)

          # download from the community update center
          FileUtils.mkdir_p(File.dirname(cache))
          open(cache+".tmp","wb") do |f|
            puts "Downloading #{short_name} #{version}"
            url = "https://updates.jenkins-ci.org/download/plugins/#{short_name}/#{version}/#{short_name}.hpi?for=ruby-plugin"
             f.write fetch(url).body
          end
          FileUtils.mv cache+".tmp", cache

          return cache
        end

        # download with redirect support
        def fetch(uri, limit = 10)
          # You should choose better exception.
          raise ArgumentError, 'HTTP redirect too deep' if limit == 0

          response = Net::HTTP.get_response(URI.parse(uri))
          case response
          when Net::HTTPSuccess     then response
          when Net::HTTPRedirection then fetch(response['location'], limit - 1)
          else
            response.error!
          end
        end

        # parse manifest file text into a hash
        def parse_manifest(txt)
          # separators
          nl = /\r\n|\n|\r[^\n]/
          secsep = /(#{nl}){2}/

          txt.split(secsep).reject { |s| s.chomp.length==0 }.map do |section|
            lines = []
            section.split(nl).each do |line|
              if line[0]==0x20
                lines.last << line[1..-1] # continuation of the previous line
              else
                lines << line
              end
            end

            # convert to hash
            hash = {}
            lines.each do |l|
              (k,v) = l.split(/: /,2)
              hash[k] = v
            end

            hash
          end
        end
      end
    end
  end
end
