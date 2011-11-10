require 'jenkins/plugin/tools/bundle'
require 'jenkins/plugin/tools/manifest'
require 'net/http'
require 'erb'

module Jenkins
  class Plugin
    module Tools
      # task for deploying a plugin
      class Release

        def initialize(spec,hpi)
          @spec = spec
          @hpi = hpi  # hpi file to release
        end

        def check_error(rsp)
          # in case of 401 Unauthorized, the server just resets the connection and Net::HTTP fails to parse the response,
          # so we don't really get any meaningful error message.
          rsp.value
        end

        def run
          cred = JenkinsCiOrg::Credential.new
          if !cred.has_credential? then
            raise Exception.new("no credential available to connect to jenkins-ci.org. Please create ~/.jenkins-ci.org. See https://wiki.jenkins-ci.org/display/JENKINS/Dot+Jenkins+Ci+Dot+Org")
          end

          http = Net::HTTP.new("maven.jenkins-ci.org",8081)

          puts "Generating POM"
          version = @spec.version+"-SNAPSHOT"
          pom = ERB.new(File.read(File.dirname(__FILE__)+"/templates/release-pom.xml.erb")).result(binding)

          path = "/content/repositories/snapshots/org/jenkins-ci/ruby-plugins/#{@spec.name}/#{@spec.version}-SNAPSHOT/#{@spec.name}-#{@spec.version}-SNAPSHOT"
          req = Net::HTTP::Put.new("#{path}.pom")
          req.body = pom
          req.basic_auth(cred.user_name,cred.password)
          check_error(http.request(req))

          puts "Uploading #{@hpi}"
          File.open(@hpi,'r') do |f|
            req = Net::HTTP::Put.new("#{path}.hpi")
            req.body_stream = f
            req.basic_auth(cred.user_name,cred.password)
            req.content_length = File.size(@hpi)
            check_error(http.request(req))
          end
        end
      end

      class JenkinsCiOrg
        #
        class Credential
          CREDENTIAL = File.expand_path("~/.jenkins-ci.org")

          def initialize
            @props = {}

            if File.exists?(CREDENTIAL) then
              File.open(CREDENTIAL,'r') do |f|
                f.each_line do |l|
                  if l[0]=='#' then
                    return  # comment
                  end

                  k,v = l.split("=",2)
                  @props[k]=v.strip
                end
              end
            end
          end

          # do we already have the credential?
          def has_credential?
            @props["userName"] && @props["password"]
          end

          def user_name
            @props["userName"]
          end

          def password
            @props["password"]
          end
        end
      end
    end
  end
end
