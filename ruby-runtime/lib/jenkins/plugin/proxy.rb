
module Jenkins
  class Plugin

    ##
    # The Jenkins Ruby API uses "proxies" which are Java subclasses of the native Jenkins
    # Java API. These proxies provide the mapping between the Java API and the idomatic
    # Ruby API. Sometimes these mappings can appear convoluted, but it is only so in order to make
    # the Ruby side as simple and clean as possible.
    #
    # This module provides common functionality for all proxies.
    module Proxy
      extend Plugin::Behavior

      implemented do |cls|
        cls.class_eval do
          include Java.org.kohsuke.stapler.StaplerProxy
        end
      end

      # Every Proxy object has a reference to the plugin to which it belongs, as well as the
      # native Ruby object which it represents.
      #
      # @param [Jenkins::Plugin] plugin the plugin from whence this proxy object came
      # @param [Object] object the implementation to which this proxy will delegate.
      # @param super_args               pass through arguments to the super type
      def initialize(plugin, object, *super_args)
        super(*super_args) if defined? super
        @plugin, @object = plugin, object
        @pluginid = @plugin.name
        @plugin.linkout object, self
      end

      # tell Stapler to go look for views from the wrapped object
      def getTarget
        @object
      end

      # Used to specify which Ruby class this will act as a proxy
      module ProxyFor
        # register this class as a proxy for `internal_class`. Jenkins
        # will auto-create instances of this class when passing to
        # ruby and vice-versa
        def proxy_for(internal_class)
          fail "not a ruby class" unless internal_class.is_a? Class
          Jenkins::Plugin::Proxies.register internal_class, self
        end
      end

      # Make sure that proxy classes do not try to persist the plugin parameter.
      # when serializing this proxy to XStream. It will be reconstructed with
      # [Unmarshal#read_completed]
      module Marshal

        # Tell XStream that we never want to persist the @plugin field
        # @param [String] field name of the field which xstream is enquiring about
        # @return [Boolean] true if this is the plugin field, otherwise delegate
        def transient?(field)
          field.to_s == "plugin" or (super if defined? super)
        end
      end

      # Reanimates Proxy objects after their values have been unserialized from XStream
      module Unmarshal

        # Once the proxy has been unmarshalled from XStream, re-find the plugin
        # that it is associated with, and use it to populate the @plugin field.
        # Also, make sure to associate this proxy with the object it represents
        # so that they remain referentially equivalent.
        def read_completed
          @plugin = Java.jenkins.model.Jenkins.getInstance().getPlugin(@pluginid).getNativeRubyPlugin()
          @plugin.linkout @object, self
        end

      end

      ##
      # Convenience methods for converting from Ruby API to Java API objects and back
      module Customs

        ##
        # convert an external Java object into a Ruby friendly object
        def import(object)
          @plugin.import(object)
        end

        ##
        # convert an internal Ruby object into a Java proxy that is free to roam about Jenkins-land
        def export(object)
          @plugin.export(object)
        end
      end

      module ClassMethods
        include Marshal
        include ProxyFor
      end

      module InstanceMethods
        include Unmarshal
        include Customs
      end
    end
  end
end
