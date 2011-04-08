require 'bundler'
Bundler::GemHelper.install_tasks

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:spec)

namespace :cucumber do
  require 'cucumber/rake/task'
  Cucumber::Rake::Task.new(:wip, 'Run features that are being worked on') do |t|
    t.cucumber_opts = "--tags @wip"
  end
  Cucumber::Rake::Task.new(:ok, 'Run features that should be working') do |t|
    t.cucumber_opts = "--tags ~@wip"
  end
  task :all => [:ok, :wip]
end

desc 'Alias for cucumber:ok'
task :cucumber => 'cucumber:ok'

desc "Start test server; Run cucumber:ok; Kill Test Server;"
task :default => [:spec, "hudson:server:killtest", "hudson:server:test"] do
  require 'socket'
  require 'net/http'
  print "waiting for at most 30 seconds for the server to start"
  tries = 1
  begin
    print "."; $stdout.flush
    tries += 1
    Net::HTTP.start("localhost", "3010") { |http| http.get('/') }
    sleep(10)
    puts ""
    result = Rake::Task["cucumber:ok"].invoke
  rescue Exception => e
    if tries <= 15
      sleep 2
      retry
    end
    raise
  ensure
    Rake::Task["hudson:server:killtest"].tap do |task|
      task.reenable
      task.invoke
    end
  end
  raise unless result
end

namespace :hudson do
  namespace :server do
    require 'fileutils'

    directory plugin_dir = File.expand_path("var/hudson/plugins")
    desc "Run a server for tests"
    task :test => plugin_dir do
      port = 3010
      control = 3011
      FileUtils.chdir(File.dirname(__FILE__)) do
        Dir["fixtures/hudson/*.hpi"].each do |plugin|
          FileUtils.cp plugin, plugin_dir
        end
        logfile = File.expand_path("var/hudson/test.log")
        puts "Launching hudson test server at http://localhost:#{port}..."
        puts "  output will be logged to #{logfile}"
        `ruby bin/hudson server --home #{File.dirname(plugin_dir)} --port #{port} --control #{control} --daemon --logfile #{logfile}`
      end
    end

    desc "Kill hudson test server if it is running."
    task :killtest do
      FileUtils.chdir(File.dirname(__FILE__)) do
        puts "Killing any running server processes..."
        `ruby bin/hudson server --control 3011 --kill 2>/dev/null`
      end
    end

  end
end

Dir['tasks/**/*.rake'].each {|f| load f}


