$:.unshift('lib')
require 'hudson'
require 'rubygems'

Gem::Specification.new do |gemspec|
  $gemspec = gemspec
  gemspec.name = gemspec.rubyforge_project = "hudson"
  gemspec.version = Hudson::VERSION
  gemspec.summary = "Painless Continuous Integration with Hudson Server"
  gemspec.description = "A suite of utilities for bringing continous integration to your projects (not the other way around) with hudson CI"
  gemspec.email = ["cowboyd@thefrontside.net", "drnicwilliams@gmail.com"]
  gemspec.homepage = "http://github.com/cowboyd/hudson.rb"
  gemspec.authors = ["Charles Lowell", "Dr Nic Williams"]
  gemspec.executables = ["hudson"]
  gemspec.require_paths = ["lib"]
  gemspec.files = Rake::FileList.new("**/*").tap do |manifest|
    manifest.exclude "tmp", "**/*.gem"
  end.to_a
  s.add_dependency("term-ansicolor", [">= 1.0.4"])
  s.add_dependency("yajl", [">= 0.7.6"])
  s.add_dependency("httparty", ["~> 0.5.2"])
  s.add_dependency("builder", ["~> 2.1.2"])
  s.add_development_dependency("cucumber", ["~> 0.7.3"])
  s.add_development_dependency("rspec", ["~> 1.3.0"])
end

desc "Build gem"
task :gem => :gemspec do
  Gem::Builder.new($gemspec).build
end

desc "Build gemspec"
task :gemspec => :clean do
  File.open("#{$gemspec.name}.gemspec", "w") do |f|
    f.write($gemspec.to_ruby)
  end
end

desc "Clean up"
task :clean do
  sh "rm -rf *.gem"
end

desc "Start test server; Run Cucumber; Kill Test Server;"
task :default => ["hudson:server:killtest", "hudson:server:test"] do
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
    
    desc "Grab the latest hudson.war from hudson-ci.org"
    task :getwar do
      sh "cd lib/hudson && rm hudson.war && wget http://hudson-ci.org/latest/hudson.war"
    end
    
  end
end


