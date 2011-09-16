
require 'pathname'

module Jenkins
  class Plugin
    class Specification

      # The name of this plugin. Will be used as a globally
      # unique identifier inside the Jenkins server
      attr_accessor :name

      # Plugin version. This is used during dependency resolution
      attr_accessor :version

      # Free form text description of the plugin. No character limit, but please, keep it civil.
      attr_accessor :description

      # A hash of dependencies, like 'foo' => '1.2.3', 'bar' => '0.0.1'
      # Our dependency handling is not smart (yet).
      attr_accessor :dependencies

      def initialize
        @dependencies = {}
        yield(self) if block_given?
      end

      # Adds `plugin_name` as a pre-requisite of
      # this plugin. This can be the name of any Jenkins plugin
      # written in Ruby, Java, or any other language. Version right
      # now must be an *exact* version number.
      def depends_on(plugin_name, version)
        dependencies[plugin_name] = version
      end

      # Make sure that your specification is not corrupt.
      def validate!
        [:name, :version, :description].each do |field|
          fail SpecificationError, "field may not be nil" unless send(field)
        end
      end

      def self.load(path)
        eval(File.read(path), binding, path, 1)
      end
    end

    SpecificationError = Class.new(StandardError)
  end
end