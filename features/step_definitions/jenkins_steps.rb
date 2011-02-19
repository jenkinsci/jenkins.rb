Given /^I have a Jenkins server running$/ do
  unless @jenkins_port
    port = 3010
    begin
      res = Net::HTTP.start("localhost", port) { |http| http.get('/api/json') }
      Jenkins::Api.base_uri "http://localhost:#{port}"
    rescue Errno::ECONNREFUSED => e
      raise Exception, "To run tests, launch jenkins in test mode: 'rake jenkins:server:test'"
    end
    @jenkins_port = port.to_s
    @jenkins_host = 'localhost'
  end
end

Given /^the Jenkins server has no current jobs$/ do
  if port = @jenkins_port
    Jenkins::Api.summary['jobs'].each do |job|
      Jenkins::Api.delete_job(job['name'])
    end
    Jenkins::Api.summary['jobs'].should == []
  else
    puts "WARNING: Run 'I have a Jenkins server running' step first."
  end
end

Given /^the Jenkins server has no slaves$/ do
  if port = @jenkins_port
    Jenkins::Api.summary['jobs'].each do |job|
      Jenkins::Api.delete_job(job['name'])
    end
    Jenkins::Api.summary['jobs'].should == []

    Jenkins::Api.nodes['computer'].each do |node|
      name = node['displayName']
      Jenkins::Api.delete_node(name) unless name == "master"
    end
    Jenkins::Api.nodes['computer'].size.should == 1
  else
    puts "WARNING: Run 'I have a Jenkins server running' step first."
  end
end

Given /^there is nothing listening on port (\d+)$/ do |port|
  lambda {
    TCPSocket.open("localhost", port) {}
  }.should raise_error
end

Given /^I cleanup any jenkins processes with control port (\d+)$/ do |port|
  @jenkins_cleanup << port
end

def try(times, interval = 1)
  begin
    times -= 1
    return yield
  rescue Exception => e
    if times >= 0
      sleep(interval)
      retry
    end
    raise e
  end
end

When /^I run jenkins server with arguments "(.*)"/ do |arguments|
  @stdout = File.expand_path(File.join(@tmp_root, "executable.out"))
  executable = File.expand_path(File.join(File.dirname(__FILE__), "/../../bin","jenkins"))
  in_project_folder do
    system "ruby #{executable.inspect} server #{arguments} > #{@stdout.inspect} 2> #{@stdout.inspect}"
  end
end


Then /^I should see a jenkins server on port (\d+)$/ do |port|
  require 'json'
  try(15, 2) do
    Jenkins::Api.base_uri "http://localhost:#{port}"
    Jenkins::Api.summary['nodeDescription'].should == "the master Jenkins node"
  end
end

When /^I (re|)create a job$/ do |override|
  override = override.blank? ? "" : " --override"
  steps <<-CUCUMBER
    When the project uses "git" scm
    When I run local executable "jenkins" with arguments "create . --host localhost --port 3010#{override}"
  CUCUMBER
end

When /^I wait for ([\S]+) build (\d+) to start$/ do |project_name, build_number|
  begin
    Timeout.timeout(10) do
      while !Jenkins::Api.build_details(project_name, build_number)
        sleep 1
      end
    end
  rescue TimeoutError
    raise "Couldn't find build #{build_number} for project #{project_name}"
  end
end

Then /^the job "([^"]*)" config "([^"]*)" should be:$/ do |job_name, xpath, string|
  raise "Cannot yet fetch XML config from non-localhost Jenkins" unless Jenkins::Api.base_uri =~ /localhost/
  require "hpricot"
  config = Hpricot.XML(File.read("#{test_jenkins_path}/jobs/#{job_name}/config.xml"))
  config.search(xpath).to_s.should == string
end

Then /^the Jenkins config "([^"]*)" should be:$/ do |xpath, string|
  raise "Cannot yet fetch XML config from non-localhost Jenkins" unless Jenkins::Api.base_uri =~ /localhost/
  require "hpricot"
  config = Hpricot.XML(File.read("#{test_jenkins_path}/config.xml"))
  config.search(xpath).to_s.should == string
end

