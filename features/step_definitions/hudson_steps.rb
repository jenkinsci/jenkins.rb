Given /^I have a Hudson server running$/ do
  unless ENV['HUDSON_PORT']
    port = 3010
    begin
      res = Net::HTTP.start("localhost", port) { |http| http.get('/api/json') }
    rescue Errno::ECONNREFUSED => e
      puts "\n\n\nERROR: To run tests, launch hudson in test mode: 'rake hudson:server:test'\n\n\n"
      exit
    end
    ENV['HUDSON_PORT'] = port.to_s
    ENV['HUDSON_HOST'] = 'localhost'
  end
end

Given /^the Hudson server has no current jobs$/ do
  if port = ENV['HUDSON_PORT']
    require "open-uri"
    require "yajl"
    hudson_info = Yajl::Parser.new.parse(open("http://localhost:#{ENV['HUDSON_PORT']}/api/json"))

    hudson_info['jobs'].each do |job|
      job_url = job['url']
      res = Net::HTTP.start("localhost", port) { |http| http.post("#{job_url}doDelete/api/json", {}) }
    end
    hudson_info = Yajl::Parser.new.parse(open("http://localhost:#{ENV['HUDSON_PORT']}/api/json"))
    hudson_info['jobs'].should == []
  else
    puts "WARNING: Run 'I have a Hudson server running' step first."
  end
end

