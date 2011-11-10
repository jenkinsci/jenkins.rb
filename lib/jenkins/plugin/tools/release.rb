require 'jenkins/plugin/tools/bundle'
require 'jenkins/plugin/tools/manifest'
require 'jenkins/jenkins-ci.org/credential'
require 'net/http'
require 'erb'

module Jenkins
  class Plugin
    module Tools
      # task for deploying a plugin
      class Release

        def initialize(spec,hpi,snapshot)
          @spec = spec
          @hpi = hpi  # hpi file to release
          @snapshot = snapshot # if true, deploy as a snapshot, otherwise as release
        end

        def check_error(rsp)
          # in case of 401 Unauthorized, the server just resets the connection and Net::HTTP fails to parse the response,
          # so we don't really get any meaningful error message.
          rsp.value # TODO: is this how we check for the error?
        end

        def run
          cred = Jenkins::CiOrg::Credential.new
          if !cred.has_credential? then
            raise Exception.new("no credential available to connect to jenkins-ci.org. Please create ~/.jenkins-ci.org. See https://wiki.jenkins-ci.org/display/JENKINS/Dot+Jenkins+Ci+Dot+Org")
          end

          http = Net::HTTP.new("maven.jenkins-ci.org",8081)

          puts @snapshot ? "deploying as a snapshot" : "deploying as a release"
          puts "Generating POM"
          version = @snapshot ? @spec.version+"-SNAPSHOT" : @spec.version
          pom = ERB.new(File.read(File.dirname(__FILE__)+"/templates/release-pom.xml.erb")).result(binding)

          path = "/content/repositories/#{@snapshot?'snapshots':'releases'}/org/jenkins-ci/ruby-plugins/#{@spec.name}/#{version}/#{@spec.name}-#{version}"
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

          puts "See http://maven.jenkins-ci.org"+File.dirname(path)
        end
      end
    end
  end
end
