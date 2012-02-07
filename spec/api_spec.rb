require File.dirname(__FILE__) + "/spec_helper"

describe Jenkins::Api do
  context "#setup_base_url" do

    it "should accept a hash with a host and port as an argument" do
      uri = Jenkins::Api.setup_base_url :host => 'hash.example.com', :port => '123'
      uri.host.should == 'hash.example.com'
      uri.port.should == 123
      uri.path.should == ''
    end

    it "should accept 'http://localhost:3010/somepath' as a string argument" do
      uri = Jenkins::Api.setup_base_url 'http://string.example.com:1/somepath'
      uri.host.should == 'string.example.com'
      uri.port.should == 1
      uri.path.should == '/somepath'
    end

    it "should accept 'http://localhost:3010/' as a :host argument" do
      uri = Jenkins::Api.setup_base_url :host => 'http://string.example.com:2'
      uri.host.should == 'string.example.com'
      uri.port.should == 2
      uri.path.should == ''
    end

    it "should accept basic auth parameters in the :host argument" do
      uri = Jenkins::Api.setup_base_url :host => 'http://foo:bar@string.example.com:2'
      uri.host.should == 'string.example.com'
      uri.port.should == 2
      uri.path.should == ''
      auth = Jenkins::Api.default_options[:basic_auth]
      auth[:username].should == 'foo'
      auth[:password].should == 'bar'
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
        uri.host.should == 'environment.example.com'
        uri.port.should == 432
      end

      it "should not let environment variables override a hash" do
        ENV['JENKINS_HOST'] = 'wrong.example.com'
        ENV['JENKINS_PORT'] = '123'
        uri = Jenkins::Api.setup_base_url :host => 'right.example.com', :port => '111'
        uri.host.should == 'right.example.com'
        uri.port.should == 111
      end

      it "should not let environment variables override a string URL" do
        ENV['JENKINS_HOST'] = 'wrong.example.com'
        ENV['JENKINS_PORT'] = '123'
        uri = Jenkins::Api.setup_base_url 'http://right.example.com:111/'
        uri.host.should == 'right.example.com'
        uri.port.should == 111
      end
    end
  end
end
