require File.dirname(__FILE__) + "/spec_helper"

describe Jenkins::Api do
  context "#setup_base_url" do

    it "should accept a hash with a host and port as an argument" do
      uri = Jenkins::Api.setup_base_url :host => 'hash.example.com', :port => '123'
      uri.host.should == 'hash.example.com'
      uri.port.should == 123
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
    end
  end
end