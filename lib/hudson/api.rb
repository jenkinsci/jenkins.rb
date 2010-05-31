require 'httparty'
require 'cgi'

module Hudson
  class Api
    include HTTParty

    headers 'content-type' => 'application/xml'
    format :xml
    # http_proxy 'localhost', '8888'
    
    def self.setup_base_url(host, port)
      base_uri "http://#{host}:#{port}"
    end
    
    # returns true if successfully create a new job on Hudson
    def self.create_job(name, job_config)
      res = post "/createItem/api/json?name=#{CGI.escape(name)}", {
        :body => job_config.to_xml,
      }
      res.code == 200
    end
    
    def self.summary
      get "/api/json"
    end
  end
end