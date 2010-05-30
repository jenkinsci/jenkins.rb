
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
    desc "Run a server for tests"
    task :test do
      port = 3010
      require "fileutils"
      FileUtils.chdir(File.dirname(__FILE__)) do
        puts "Launching hudson test server at http://localhost:#{port}..."
        `ruby bin/hudson server /tmp/test_hudson -p #{port}`
      end
    end
  end
end