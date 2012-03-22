module Jenkins
  module Model
    # mix-in on top of the subtypes of the Describable Java class
    # to add standard behaviour as a proxy to Ruby object
    module DescribableProxy
      include Jenkins::Plugin::Proxy
      implemented do |cls|
        cls.class_eval do
          include Java.jenkins.ruby.Get
        end
      end
      def getDescriptor
        @plugin.descriptors[@object.class]
      end

      def get(name)
        @object.respond_to?(name) ? @object.send(name) : nil
      end
    end
  end
end
