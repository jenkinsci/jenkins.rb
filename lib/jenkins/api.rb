require 'httparty'
require 'cgi'
require 'uri'
require 'json'

require 'jenkins/core_ext/hash'
require 'jenkins/config'

module Jenkins
  module Api
    include HTTParty

    headers 'content-type' => 'application/json'
    format :json
    # http_proxy 'localhost', '8888'
    
    JobAlreadyExistsError = Class.new(Exception)

    def self.setup_base_url(options)
      options = options.with_clean_keys
      # Thor's HashWithIndifferentAccess is based on string keys which URI::HTTP.build ignores
      options = options.inject({}) { |mem, (key, val)| mem[key.to_sym] = val; mem }
      options[:host] ||= ENV['JENKINS_HOST']
      options[:port] ||= ENV['JENKINS_PORT']
      options[:port] &&= options[:port].to_i
      return false unless options[:host] || Jenkins::Config.config["base_uri"]
      uri = options[:host] ? URI::HTTP.build(options) : Jenkins::Config.config["base_uri"]
      base_uri uri.to_s
      uri
    end

    # returns true if successfully create a new job on Jenkins
    # +job_config+ is a Jenkins::JobConfigBuilder instance
    # +options+ are:
    #   :override - true, will delete any existing job with same name, else error
    #
    # returns true if successful, else false
    #
    # TODO Exceptions?
    def self.create_job(name, job_config, options = {})
      options = options.with_clean_keys
      delete_job(name) if options[:override]
      begin
        res = post "/createItem/api/xml?name=#{CGI.escape(name)}", {
          :body => job_config.to_xml, :format => :xml, :headers => { 'content-type' => 'application/xml' }
        }
        if res.code.to_i == 200
          cache_base_uri
          true
        else
          require "hpricot"
          doc = Hpricot(res.body)
          error_msg = doc.search("td#main-panel p")
          unless error_msg.inner_text.blank?
            $stderr.puts error_msg.inner_text
          else
            # TODO - what are the errors we get?
            puts "Server error:"
            p res.code
            puts res.body
          end
          false
        end
      rescue REXML::ParseException => e
        # For some reason, if the job exists we get back half a page of HTML
        raise JobAlreadyExistsError.new(name)
      end
    end
    
    # Attempts to delete a job +name+
    def self.delete_job(name)
      res = post_plain "#{job_url name}/doDelete"
      res.code.to_i == 302
    end
    
    def self.build_job(name)
      res = get_plain "/job/#{name}/build"
      res.code.to_i == 302
    end

    def self.summary
      json = get "/api/json"
      cache_base_uri
      json
    end
    
    def self.job_names
      summary["jobs"].map {|job| job["name"]}
    end

    # Return hash of job statuses
    def self.job(name)
      begin
        json = get "/job/#{name}/api/json"
        cache_base_uri
        json
      rescue Crack::ParseError
        false
      end
    end

    # Return a hash of information about a build.
    def self.build_details(job_name, build_number)
      begin
        json = get "/job/#{job_name}/#{build_number}/api/json"
        cache_base_uri
        json
      rescue Crack::ParseError
        false
      end
    end

    def self.nodes
      json = get "/computer/api/json"
      cache_base_uri
      json
    end

    # Adds SSH nodes only, for now
    def self.add_node(options = {})
      options = options.with_clean_keys
      default_options = Hash.new
      if options[:vagrant]
        default_options.merge!(
          :slave_port  => 2222,
          :slave_user  => 'vagrant',
          :master_key  => "/Library/Ruby/Gems/1.8/gems/vagrant-0.6.7/keys/vagrant", # FIXME - hardcoded master username assumption
          :slave_fs    => "/vagrant/tmp/jenkins-slave/",
          :description => "Automatically created by Jenkins.rb",
          :executors   => 2,
          :exclusive   => true
        )
      else
        default_options.merge!(
          :slave_port  => 22,
          :slave_user  => 'deploy',
          :master_key  => "/home/deploy/.ssh/id_rsa", # FIXME - hardcoded master username assumption
          :slave_fs    => "/data/jenkins-slave/",
          :description => "Automatically created by Jenkins.rb",
          :executors   => 2,
          :exclusive   => true
        )
      end
      options    = default_options.merge(options)
      
      slave_host = options[:slave_host]
      name       = options[:name] || slave_host
      labels     = options[:labels].split(/\s*,\s*/).join(' ') if options[:labels]

      type = "hudson.slaves.DumbSlave$DescriptorImpl"

      fields = {
        "name" => name,
        "type" => type,

        "json"                => {
          "name"              => name,
          "nodeDescription"   => options[:description],
          "numExecutors"      => options[:executors],
          "remoteFS"          => options[:slave_fs],
          "labelString"       => labels,
          "mode"              => options[:exclusive] ? "EXCLUSIVE" : "NORMAL",
          "type"              => type,
          "retentionStrategy" => { "stapler-class"  => "hudson.slaves.RetentionStrategy$Always" },
          "nodeProperties"    => { "stapler-class-bag" => "true" },
          "launcher"          => {
            "stapler-class" => "hudson.plugins.sshslaves.SSHLauncher",
            "host"          => slave_host,
            "port"          => options[:slave_port],
            "username"      => options[:slave_user],
            "privatekey"    => options[:master_key],
          }
        }.to_json
      }

      url = URI.parse("#{base_uri}/computer/doCreateItem")

      req = Net::HTTP::Post.new(url.path)
      req.set_form_data(fields)

      http = Net::HTTP.new(url.host, url.port)

      response = http.request(req)
      case response
      when Net::HTTPFound
        { :name => name, :slave_host => slave_host }
      else
        # error message looks like:
        # <td id="main-panel">
        # <h1>Error</h1><p>Slave called 'localhost' already exists</p>
        require "hpricot"
        error = Hpricot(response.body).search("td#main-panel p").text
        unless error.blank?
          puts error
        else
          puts response.body # so we can find other errors
        end
        false
      end
    end
    
    def self.delete_node(name)
      post_plain("#{base_uri}/computer/#{CGI::escape(name).gsub('+', '%20')}/doDelete/api/json")
    end

    # Helper for POST that don't barf at Jenkins's crappy API responses
    def self.post_plain(path, options = {})
      options = options.with_clean_keys
      uri = URI.parse base_uri
      res = Net::HTTP.start(uri.host, uri.port) { |http| http.post(path, options) }
    end
    
    # Helper for GET that don't barf at Jenkins's crappy API responses
    def self.get_plain(path, options = {})
      options = options.with_clean_keys
      uri = URI.parse base_uri
      res = Net::HTTP.start(uri.host, uri.port) { |http| http.get(path, options) }
    end
    
    private
    def self.cache_base_uri
      Jenkins::Config.config["base_uri"] = base_uri
      Jenkins::Config.store!
    end
    
    def self.job_url(name)
      "#{base_uri}/job/#{name}"
    end
  end
end
