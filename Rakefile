
desc "Grab the latest hudson.war from hudson-ci.org"
task :getwar do
  sh "cd lib/hudson && rm hudson.war && wget http://hudson-ci.org/latest/hudson.war"
end

desc "Clean up"
task :clean do
  sh "rm -rf *.gem"
end

namespace :hudson do
  namespace :server do
    require 'fileutils'

    desc "Run a server for tests"
    task :test do
      port = 3010
      control = 3011

      FileUtils.chdir(File.dirname(__FILE__)) do
        logfile = File.join(File.dirname(__FILE__), "tmp", "test_hudson.log")
        puts "Launching hudson test server at http://localhost:#{port}..."
        puts "  output will be logged to #{logfile}"
        `ruby bin/hudson server /tmp/test_hudson -p #{port} -c #{control} --daemon -l #{logfile}`
      end
    end

    desc "Kill hudson test server if it is running."
    task :killtest do
      FileUtils.chdir(File.dirname(__FILE__)) do
        puts "Killing any running server processes..."
        `ruby bin/hudson server -c 3011 -k 2>/dev/null`
      end
    end
  end

  desc "Start test server. Run Cucumber. Kill Test Server. Helpful for CI"
  task :selftest => ["hudson:server:killtest", "hudson:server:test"] do
    begin
      puts "waiting for 10 seconds for the server to start"
      sleep(10)
      require 'cucumber/rake/task'
      Cucumber::Rake::Task.new
      Rake::Task["cucumber"].invoke
    ensure
      Rake::Task["hudson:server:killtest"].tap do |task|
        task.reenable
        task.invoke
      end
    end
  end
end
