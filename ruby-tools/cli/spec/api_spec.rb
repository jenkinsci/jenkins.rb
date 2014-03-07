require File.dirname(__FILE__) + "/spec_helper"

describe Jenkins::Api do
  describe "#setup_base_url" do
    it "should accept a hash with a host and port as an argument" do
      uri = Jenkins::Api.setup_base_url :host => 'hash.example.com', :port => '123'
      expect(uri.host).to eq('hash.example.com')
      expect(uri.port).to eq(123)
      expect(uri.path).to eq('')
    end

    it "should accept 'http://localhost:3010/somepath' as a string argument" do
      uri = Jenkins::Api.setup_base_url 'http://string.example.com:1/somepath'
      expect(uri.host).to eq('string.example.com')
      expect(uri.port).to eq(1)
      expect(uri.path).to eq('/somepath')
    end

    it "should accept 'http://localhost:3010/' as a :host argument" do
      uri = Jenkins::Api.setup_base_url :host => 'http://string.example.com:2'
      expect(uri.host).to eq('string.example.com')
      expect(uri.port).to eq(2)
      expect(uri.path).to eq('')
    end

    it "should accept basic auth parameters in the :host argument" do
      uri = Jenkins::Api.setup_base_url :host => 'http://foo:bar@string.example.com:2'
      expect(uri.host).to eq('string.example.com')
      expect(uri.port).to eq(2)
      expect(uri.path).to eq('')
      auth = Jenkins::Api.default_options[:basic_auth]
      expect(auth[:username]).to eq('foo')
      expect(auth[:password]).to eq('bar')
    end

    context "with environment variables" do
      after :each do
        ENV.delete 'JENKINS_HOST'
        ENV.delete 'JENKINS_PORT'
      end

      it "should accept the environment variables JENKINS_HOST and JENKINS_PORT" do
        ENV['JENKINS_HOST'] = 'environment.example.com'
        ENV['JENKINS_PORT'] = '432'
        uri = Jenkins::Api.setup_base_url
        expect(uri.host).to eq('environment.example.com')
        expect(uri.port).to eq(432)
      end

      it "should not let environment variables override a hash" do
        ENV['JENKINS_HOST'] = 'wrong.example.com'
        ENV['JENKINS_PORT'] = '123'
        uri = Jenkins::Api.setup_base_url :host => 'right.example.com', :port => '111'
        expect(uri.host).to eq('right.example.com')
        expect(uri.port).to eq(111)
      end

      it "should not let environment variables override a string URL" do
        ENV['JENKINS_HOST'] = 'wrong.example.com'
        ENV['JENKINS_PORT'] = '123'
        uri = Jenkins::Api.setup_base_url 'http://right.example.com:111/'
        expect(uri.host).to eq('right.example.com')
        expect(uri.port).to eq(111)
      end
    end
  end
end
