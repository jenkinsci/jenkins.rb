
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

      # we take a fully-qualified class name, like Abc::Def::GhiJkl to underscore-separated tokens, like abc/def/ghi_jkl
      # and then look for config.* (where *=.erb, .haml, ...)
      def getConfigPage
        "/#{name_to_path}/config".tap { |path|
          puts "getConfigPage -> #{path}"
        }
      end

      def getGlobalConfigPage
        # TODO: use Descriptor.getPossibleViewNames() that's made protected in 1.441 when it gets released
        base = "/#{name_to_path}/global"
        [base+".erb",base+".haml"].find { |n|
          self.class.java_class.class_loader.getResource(n)
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

      # compute the path name of views for this class
      def name_to_path
        # camel case to underscore conversion taken from ActiveSupport::Inflector::underscore,
        # which is MIT-licensed.
        @impl.name.split('::').join('/').gsub(/::/, '/').
            gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2').
            gsub(/([a-z\d])([A-Z])/, '\1_\2').
            tr("-", "_").
            downcase
      end
    end

  end
end
