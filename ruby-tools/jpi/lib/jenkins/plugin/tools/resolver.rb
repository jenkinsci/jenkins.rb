require 'net/http'

module Jenkins
  class Plugin
    module Tools
      class Resolver

        def initialize(spec, dir)
          @spec = spec
          @dir = dir
          FileUtils.mkdir_p(dir) unless File.directory? @dir
        end

        def resolve!
          @spec.dependencies.each do |name, version|
            FileUtils.cp resolve(name, version), @dir
          end
        end

        def resolve(short_name,version)
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
            url = "http://updates.jenkins-ci.org/download/plugins/#{short_name}/#{version}/#{short_name}.hpi?for=ruby-plugin"
            puts "  from #{url}"
            f.write fetch(url).body
          end
          FileUtils.mv cache+".tmp", cache

          return cache
        end

        # download with redirect support
        def fetch(uri, limit = 10)
          # You should choose better exception.
          raise ArgumentError, 'HTTP redirect too deep' if limit == 0

          http = if ENV['HTTP_PROXY'] || ENV['http_proxy']
                   proxy_uri = URI.parse(ENV['HTTP_PROXY'] || ENV['http_proxy'])
                   Net::HTTP::Proxy(proxy_uri.host, 
                                    proxy_uri.port, 
                                    proxy_uri.user,
                                    proxy_uri.password)
                 else
                   Net::HTTP
                 end

          response = http.get_response(URI.parse(uri))
          case response
          when Net::HTTPSuccess     then response
          when Net::HTTPRedirection then fetch(response['location'], limit - 1)
          else
            response.error!
          end
        end
      end
    end
  end
end
