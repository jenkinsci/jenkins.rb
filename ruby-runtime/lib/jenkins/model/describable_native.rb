module Jenkins
  module Model
    module DescribableNative
      include Describable

      implemented do |cls|
        cls.class_eval do
          include Java.jenkins.ruby.Get
        end
      end

      def getDescriptor
        Jenkins.plugin.descriptors[@object.class]
      end

      def get(name)
        @object.respond_to?(name) ? @object.send(name) : nil
      end
    end
  end
end
