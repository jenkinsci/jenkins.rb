require 'httparty'
require 'cgi'
require 'uri'
require 'json'

require 'jenkins/core_ext/hash'
require 'jenkins/config'
#require 'jenkins/connection'

module Jenkins
  module Api
    include HTTParty

    headers 'content-type' => 'application/json'
    format :json
    # http_proxy 'localhost', '8888'

    JobAlreadyExistsError = Class.new(Exception)
    NoConfigError = Class.new(Exception)

    def self.setup_base_url(options)
      options = options.with_clean_keys
      # Thor's HashWithIndifferentAccess is based on string keys which URI::HTTP.build ignores
      options = options.inject({}) { |mem, (key, val)| mem[key.to_sym] = val; mem }
      options[:host] ||= ENV['JENKINS_HOST']
      options[:port] ||= ENV['JENKINS_PORT']
      options[:port] &&= options[:port].to_i
      options = setup_authentication(options)
      return false unless options[:host] || Jenkins::Config.config["base_uri"]
      uri_class = options.delete(:ssl) ? URI::HTTPS : URI::HTTP
      uri = options[:host] ? uri_class.build(options) : Jenkins::Config.config["base_uri"]
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
        if @username && @password && @options
          conn = Jenkins::Connection.new(@username, @password, @options)
          res = conn.post("/createItem/api/xml?name=#{CGI.escape(name)}", job_config.to_xml, 'application/xml')
        else
          res = post "/createItem/api/xml?name=#{CGI.escape(name)}", {
            :body => job_config.to_xml, :format => :xml, :headers => { 'content-type' => 'application/xml' }
          }
        end
        if res.code.to_i == 200
          cache_configuration!
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
    
    # returns true if successfully updated a new job on Jenkins
    # Available Options:
    # - to update is nodes on a matrix-project
    # - disable a job
    def self.update_job(name, opts={})
      options = {
        :nodes => [],
        :disable => false
      }.merge!(opts)
      
      # Getting the config.xml from Jenkins
      xml_data = nil
      res = get_plain "/job/#{name}/config.xml"
      if res.code.to_i == 200
        xml_data = res.body
      else
        raise NoConfigError.new(res.body)
      end
      
      doc = REXML::Document.new(xml_data)
      
      # Modifying config.xml to remove old nodes and add our new nodes if we want to update nodes.
      if !options[:nodes].empty?
        doc.elements.delete_all('matrix-project/axes/hudson.matrix.LabelAxis/values/string')
        el = nil
        doc.elements.each('matrix-project/axes/hudson.matrix.LabelAxis/values') do |element|
          el = element if element.name == "values"
        end
        options[:nodes].each_with_index do |node, index|
          i = index + 1
          el.add_element('string')
          el.elements["string[#{i}]"].text = node
        end
      end
      
      # Disabling the job if we set disable to true
      if options[:disable]
        doc.root.elements["disabled"].text = "true"
      end
      
      # Posting config.xml back to Jenkins
      xml_data = doc.to_s
      if @username && @password && @options
        conn = Jenkins::Connection.new(@username, @password, @options)
        res = conn.post("/job/#{CGI.escape(name)}/config.xml", xml_data, 'application/xml')
      else
        res = post "/job/#{CGI.escape(name)}/config.xml", {
          :body => xml_data, :format => :xml, :headers => { 'content-type' => 'application/xml' }
        }
      end
      if res.code.to_i == 200
        cache_configuration!
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
      cache_configuration!
      json
    end

    def self.job_names
      summary["jobs"].map {|job| job["name"]}
    end

    # Return hash of job statuses
    def self.job(name)
      begin
        json = get "/job/#{name}/api/json"
        cache_configuration!
        json
      rescue Crack::ParseError
        false
      end
    end

    # Return a hash of information about a build.
    def self.build_details(job_name, build_number)
      begin
        json = get "/job/#{job_name}/#{build_number}/api/json"
        cache_configuration!
        json
      rescue Crack::ParseError
        false
      end
    end

    def self.nodes
      json = get "/computer/api/json"
      cache_configuration!
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
          :slave_pass  => '',
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
          :slave_pass  => '',
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
            "password"      => options[:slave_pass],
            "privatekey"    => options[:master_key],
          }
        }.to_json
      }
      
      if @username && @password && @options
        conn = Jenkins::Connection.new(@username, @password, @options)
        response = conn.post("/computer/doCreateItem", nil, nil, fields)
      else
        url = URI.parse("#{base_uri}/computer/doCreateItem")

        req = Net::HTTP::Post.new(url.path)
        req.set_form_data(fields)

        http = Net::HTTP.new(url.host, url.port)

        response = http.request(req)
      end
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
    def self.post_plain(path, data = "", options = {})
      options = options.with_clean_keys
      uri = URI.parse base_uri
      res = Net::HTTP.start(uri.host, uri.port) do |http|
        if RUBY_VERSION =~ /1.8/
          http.post(path, options)
        else
          http.post(path, data, options)
        end
      end
    end

    # Helper for GET that don't barf at Jenkins's crappy API responses
    def self.get_plain(path, options = {})
      options = options.with_clean_keys
      if @username && @password && @options
        conn = Jenkins::Connection.new(@username, @password, @options)
        res  = conn.get(path)
      else
        uri = URI.parse base_uri
        res = Net::HTTP.start(uri.host, uri.port) { |http| http.get(path, options) }
      end
    end

    def self.cache_configuration!
      Jenkins::Config.config["base_uri"] = base_uri
      Jenkins::Config.config["basic_auth"] = default_options[:basic_auth]
      Jenkins::Config.store!
    end

    private
    def self.setup_authentication(options)
      username, password, form = options.delete(:username), options.delete(:password), options.delete(:form)
      if username && password && form
        form_auth(username, password, options)
      elsif username && password
        basic_auth username, password
      elsif Jenkins::Config.config["basic_auth"]
        basic_auth Jenkins::Config.config["basic_auth"]["username"],
                   Jenkins::Config.config["basic_auth"]["password"]
      end
      options
    end
    
    def self.form_auth(username, password, options)
      @username = username
      @password = password
      @options  = options
      #Jenkins::Connection.new(username, password, options)
    end

    def self.job_url(name)
      "#{base_uri}/job/#{name}"
    end
  end
  
  class LoginError < RuntimeError
  end
  class UnhandledResponse < RuntimeError
  end
  class Connection
    
    URL = "/j_acegi_security_check"
    attr :url, true
    attr :user, false
    attr :pass, false
    attr :connection, true
    attr :debug, true
    attr :cookie, true
    
    def initialize(user, pass, opts={})
      options = {
        :debug => false
      }.merge! opts
      @debug = options[:debug]

      @user = user
      @pass = pass
      @host = "http://#{options[:host]}"
      @url = URI.parse(@host + URL)
      @url.port = options[:port]
      
      # Handles http/https in url string
      @ssl = false
      @ssl = true if @url.scheme == "https"
      
      @connection = false
      login!
      raise LoginError, "Invalid Username or Password" unless logged_in?
    end
    
    def get(path)
      request = Net::HTTP::Get.new(path, header)
      response = @connection.request(request)
      case response
        when Net::HTTPOK
          return response
        when Net::HTTPFound
          return response
        when Net::HTTPUnauthorized
          login!
          get(path)
        when Net::HTTPForbidden
          raise LoginError, "Invalid Username or Password" 
        else 
          raise UnhandledResponse, "Can't handle response #{response}"
      end
    end
    
    def post(path, body=nil, content_type=nil, fields=nil)
      #puts body
      #puts header(content_type)
      request = Net::HTTP::Post.new(path, header(content_type))
      request.body = body if body
      request.set_form_data(fields) if fields
      response = @connection.request(request)
      case response
        when Net::HTTPOK
          return response
        when Net::HTTPFound
          return response
        when Net::HTTPBadRequest
          return response
        when Net::HTTPUnauthorized
          login!
          post(path, body, content_type)
        when Net::HTTPForbidden
          raise LoginError, "Invalid Username or Password" 
        else 
          raise UnhandledResponse, "Can't handle response #{response}"
      end
    end
    
    protected
    
    # Attempt to login to Jenkins
    def login!
      connect! unless connected?
      body = {
        #:Submit     => 'log in',
        #:from       => '/',
        :j_username => @user,
        :j_password => @pass
      }
      
      request = Net::HTTP::Post.new(@url.path)
      request.body = wrap_body(body)
      response = @connection.request(request)
      
      if response["Set-Cookie"]
        @cookie = response["Set-Cookie"].split(/;/)[0]
      else
        raise LoginError, "Invalid Username or Password"
      end
      
    end
    
    # Check to see if we are logged in or not
    def logged_in?
      return false unless @cookie
      true
    end
    
    # Check to see if we have an HTTP/S Connection
    def connected?
      return false unless @connection
      return false unless @connection.started?
      true
    end
    
    # Connect to the Jenkins Server
    def connect!
      @connection = Net::HTTP.new(@url.host, @url.port)
      if @ssl
        @connection.use_ssl = true
        @connection.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      @connection.start
    end
    
    def wrap_body(params={})
      body = ["Submit=log%20in", "from=%2F"]
      params.each_pair do |k,v|
        body << "#{k.to_s}=#{v.to_s}"
      end
      body = body.join('&')
      body.insert(0, "?")
      body
    end
    
    def header(content_type=nil)
      if @cookie && content_type
        {'Cookie' => @cookie, 'content-type' => content_type, 'Accept-Encoding' => ''}
      elsif @cookie
        {'Cookie' => @cookie, 'Accept-Encoding' => ''}
      else
        {}
      end
    end
    
  end
end
