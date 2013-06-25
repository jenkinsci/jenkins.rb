namespace :test do
  desc 'Run the tests for the jpi tool'
  task :ruby_runtime do
    sh 'cd ruby-runtime && bundle install && rake spec'
  end

  desc 'Run the tests for the jpi tool'
  task :jpi do
    sh 'cd ruby-tools/jpi && bundle install && rake cucumber'
  end

  desc 'Run the tests for the jenkins.rb CLI'
  task :cli do
    sh 'cd ruby-tools/cli && bundle install && rake spec cucumber'
  end
end

desc 'Run all the tests'
task :test => ['test:ruby_runtime', 'test:jpi', 'test:cli']
task :default => :test
