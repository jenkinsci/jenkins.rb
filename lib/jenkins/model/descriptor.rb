
require 'json'

module Jenkins
  module Model
    class Descriptor < Java.hudson.model.Descriptor

      def initialize(impl, plugin, java_type)
        super(java_type)
        @impl, @plugin, @java_type = impl, plugin, java_type
      end

      def getDisplayName
        @impl.display_name
      end

      def getId()
        "#{@plugin.name}-#{@impl.name}"
      end

      def getT()
        @java_type
      end

      # TODO: We removed @name from Descriptor (see playground) so we need to use another name.
      # Just use class name which is in CamelCase.
      def getConfigPage
        "/#{name_to_path}/config".tap { |path|
          puts "getConfigPage -> #{path}"
        }
      end

      # TODO: We removed @name from Descriptor (see playground) so we need to use another name.
      # Just use class name which is in CamelCase.
      def getGlobalConfigPage
        "/#{name_to_path}/global".tap { |path|
          puts "getGlobalConfigPage -> #{path}"
        }
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

      def name_to_path
        @impl.name.split('::').join('/')
      end
    end

  end
end
