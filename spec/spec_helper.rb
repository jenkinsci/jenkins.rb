begin
  require 'rspec'
rescue LoadError
  require 'rubygems' unless ENV['NO_RUBYGEMS']
  gem 'rspec'
  require 'rspec'
end

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'hudson'

module ConfigFixtureLoaders
  def config_xml(name, variation = nil)
    name += ".#{variation}" if variation
    @@config_fixture_loaders ||= {}
    @@config_fixture_loaders[name] ||= File.read(File.dirname(__FILE__) + "/fixtures/#{name}.config.xml")
    @@config_fixture_loaders[name]
  end
end