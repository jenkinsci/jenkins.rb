require 'httparty'
require 'cgi'

module Hudson
  class Api
    include HTTParty

    headers 'content-type' => 'application/json'
    format :json
    # http_proxy 'localhost', '8888'
    
    def self.setup_base_url(options)
      server_name, host, port = options[:server], options[:host], options[:port]
      return false unless host || server_name
      base_uri "http://#{host}:#{port}"
    end
    
    # returns true if successfully create a new job on Hudson
    def self.create_job(name, job_config)
      res = post "/createItem/api/xml?name=#{CGI.escape(name)}", {
        :body => job_config.to_xml, :format => :xml, :headers => { 'content-type' => 'application/xml' }
      }
      if res.code == 200
        true
      else
        require "hpricot"
        puts "Server error:"
        puts Hpricot(res.body).search("//body").text
        false
      end
    end
    
    def self.summary
      get "/api/json"
    end
    
    # Return hash of job sta
    def self.job(name)
      get "/job/#{name}/api/json"
    end
  end
end