require 'httparty'
require 'cgi'

module Hudson
  class Api
    include HTTParty

    headers 'content-type' => 'application/json'
    format :json
    http_proxy 'localhost', '8888'
    
    def self.setup_base_url(host, port)
      base_uri "http://#{host}:#{port}"
    end
    
    def self.create_job(name, job_config)
      post "/createItem/api/json?name=#{CGI.escape(name)}", {
        :body => job_config.to_xml,
      }
    end
    
    def self.summary
      get "/api/json"
    end
  end
end