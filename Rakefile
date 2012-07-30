
namespace :test do
  desc 'Run the tests for the jpi tool'
  task :jpi do
  end

  desc 'Run the tests for the jenkins.rb CLI'
  task :cli do
    sh '(cd ruby-tools/cli && bundle install && rake spec cucumber)'
  end
end


desc 'Run all the tests'
task :test => ['test:jpi', 'test:cli']
task :default => :test
