require 'bundler'
class Bundler::GemHelper
  def version_tag
    "runtime-v#{version}"
  end
  install_tasks
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)
task :spec => :compile

require 'jenkins/war'
Jenkins::War.classpath
ClassPath =  FileList[File.join(ENV['HOME'], '.jenkins', 'wars', Jenkins::War::VERSION, "**/*.jar")].to_a.join(':')

desc "compile java source code"
task "compile" => "target" do
  puts command = "javac -classpath #{ClassPath} #{FileList['src/**/*.java']} -d target"
  system(command)
end

require 'rake/clean'
directory "target"
CLEAN.include("target")

task :default => [:compile, :spec]
