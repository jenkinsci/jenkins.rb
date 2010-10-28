require 'rubygems'
require 'bundler/setup'

$:.unshift('lib')
require 'hudson'

Gem::Specification.new do |s|
  $gemspec = s
  s.name = s.rubyforge_project =  "hudson"
  s.version = Hudson::VERSION
  s.summary = "Painless Continuous Integration with Hudson Server"
  s.description = "A suite of utilities for bringing continous integration to your projects (not the other way around) with hudson CI"
  s.email = ["cowboyd@thefrontside.net", "drnicwilliams@gmail.com"]
  s.homepage = "http://github.com/cowboyd/hudson.rb"
  s.authors = ["Charles Lowell", "Dr Nic Williams"]
  s.executables = ["hudson"]
  s.require_paths = ["lib"]
  s.files = Rake::FileList.new("**/*").tap do |manifest|
    manifest.exclude "tmp", "**/*.gem"
  end.to_a
  s.add_dependency("term-ansicolor", [">= 1.0.4"])
  s.add_dependency("yajl-ruby", [">= 0.7.6"])
  s.add_dependency("httparty", ["~> 0.5.2"])
  s.add_dependency("builder", ["~> 2.1.2"])
  s.add_dependency("thor", ["= 0.14.2"])
  s.add_dependency("hpricot")
  s.add_development_dependency("rake", ["~> 0.8.7"])
  s.add_development_dependency("cucumber", ["~> 0.9.0"])
  s.add_development_dependency("rspec", ["~> 2.0.0"])
  s.add_development_dependency("json", ["~>1.4.0"])
  s.add_development_dependency("awesome_print")
  s.add_development_dependency("rubyzip")
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
task :default => ["hudson:server:killtest", "hudson:server:test"] do
  require 'socket'
  print "waiting for at most 30 seconds for the server to start"
  tries = 1
  begin
    print "."; $stdout.flush
    tries += 1
    Net::HTTP.start("localhost", "3010") { |http| http.get('/') }
    sleep(10)
    puts ""
    Rake::Task["cucumber:ok"].invoke
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
end

namespace :hudson do
  namespace :server do
    require 'fileutils'

    desc "Run a server for tests"
    task :test do
      port = 3010
      control = 3011

      FileUtils.chdir(File.dirname(__FILE__)) do
        logfile = File.join("/tmp", "test_hudson.log")
        puts "Launching hudson test server at http://localhost:#{port}..."
        puts "  output will be logged to #{logfile}"
        `ruby bin/hudson server --home /tmp/test_hudson --port #{port} --control #{control} --daemon --logfile #{logfile}`
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


