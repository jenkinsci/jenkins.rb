require "bundler"
Bundler.setup

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'jenkins'
require 'nokogiri'

module ConfigFixtureLoaders
  def config_xml(name, variation = nil)
    name += ".#{variation}" if variation
    @@config_fixture_loaders ||= {}
    @@config_fixture_loaders[name] ||= File.read(File.dirname(__FILE__) + "/fixtures/#{name}.config.xml")
    @@config_fixture_loaders[name]
  end
end
