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
task :default => [:spec, "jenkins:server:killtest", "jenkins:server:test"] do
  begin
    result = Rake::Task["cucumber:ok"].invoke
  ensure
    Rake::Task["jenkins:server:killtest"].execute
  end
  raise unless result
end

# This verifies that Jenkins is started
# and that it is ready to accept requests.
def wait_for_server_start
  require 'socket'
  require 'net/http'
  tries = 1
  max_tries = 30
  successes = 0
  max_successes = 2
  wait = 5
  print "Waiting for the server to start (max tries: #{max_tries} with a #{wait} second pause between tries): "
  begin
    while tries <= max_tries
      tries += 1
      begin
        Net::HTTP.start("localhost", "3010") do |http|
          response = http.get('/')
          if response.code == "200"
            print "O"
            successes += 1
            return true if successes >= max_successes
          else
            print "o"
          end
        end
      rescue SystemCallError => e
        successes = 0
        if tries == max_tries
          print "!"
          raise
        end
        print "."
      end
      $stdout.flush
      sleep(wait)
    end
  ensure
    puts # Ensure a newline gets added
    $stdout.flush
  end
  return false
end

namespace :jenkins do
  namespace :server do
    require 'fileutils'

    port = 3010
    control = 3011
    directory plugin_dir = File.expand_path("../var/jenkins/plugins", __FILE__)

    desc "Run a server for tests"
    task :test => plugin_dir do
      FileUtils.chdir(File.dirname(__FILE__)) do
        Dir["fixtures/jenkins/*.hpi"].each do |plugin|
          FileUtils.cp plugin, plugin_dir
        end
        logfile = File.expand_path("../var/jenkins/test.log", __FILE__)
        puts "Launching jenkins test server at http://localhost:#{port}..."
        puts "  output will be logged to #{logfile}"
        `bundle exec bin/jenkins server --home #{File.dirname(plugin_dir)} --port #{port} --control #{control} --daemon --logfile #{logfile}`
      end
      wait_for_server_start
    end

    desc "Kill jenkins test server if it is running."
    task :killtest do
      FileUtils.chdir(File.dirname(__FILE__)) do
        puts "Killing any running server processes..."
        `ruby bin/jenkins server --control #{control} --kill 2>/dev/null`
      end
    end

  end
end

Dir['tasks/**/*.rake'].each {|f| load f}
