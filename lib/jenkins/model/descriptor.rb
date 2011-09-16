
require 'json'

module Jenkins
  module Model
    class Descriptor < Java.hudson.model.Descriptor

      def initialize(impl, plugin, java_type)
        super(Java.org.jruby.RubyObject.java_class)
        @impl, @plugin, @java_type = impl, plugin, java_type
      end

      def getDisplayName
        @impl.display_name
      end

      def getT()
        @java_type
      end

      def newInstance(request, form)
        properties = JSON.parse(form.toString(2))
        properties.delete("kind")
        properties.delete("stapler-class")
        instance = construct(properties)
        puts "instance created: #{instance} (#{@java_type})"
        return @plugin.export(instance)
      end

      private

      def construct(attrs)
        @impl.new(attrs)
      rescue ArgumentError
        @impl.new
      end
    end

  end
end
