Given /^I have a Hudson server running$/ do
  unless @hudson_port
    port = 3010
    begin
      res = Net::HTTP.start("localhost", port) { |http| http.get('/api/json') }
    rescue Errno::ECONNREFUSED => e
      puts "\n\n\nERROR: To run tests, launch hudson in test mode: 'rake hudson:server:test'\n\n\n"
      exit
    end
    @hudson_port = port
  end
end

Given /^the Hudson server has no current jobs$/ do
  if @hudson_port
    require "open-uri"
    require "yajl"
    hudson_info = Yajl::Parser.new.parse(open("http://localhost:#{@hudson_port}/api/json"))

    require "pp"
    print "Jobs to delete: "
    pp hudson_info['jobs']

    hudson_info['jobs'].each do |job|
      job_url = job['url']
      %x{curl -v -F Submit=Yes "#{job_url}doDelete/api/json"}
    end
    hudson_info = Yajl::Parser.new.parse(open("http://localhost:#{@hudson_port}/api/json"))
    hudson_info['jobs'].should == []
  end
end

