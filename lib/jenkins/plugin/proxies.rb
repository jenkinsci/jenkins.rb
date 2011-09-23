

module Jenkins
  class Plugin

    ExportError = Class.new(StandardError)
    ImportError = Class.new(StandardError)
    NativeJavaObject = Struct.new(:native)

    # Maps JRuby objects part of the idomatic Ruby API
    # to a plain Java object representation and vice-versa.
    #
    # One of the pillars of Jenkins Ruby plugins is that writing
    # plugins must "feel" like native Ruby, and not merely like
    # scripting Java with Ruby. To this end, jenkins-plugins provides
    # a idiomatic Ruby API that sits on top of the native Jenkins
    # Java API with which plugin developers can interact.
    #
    # This has two consequences. Native Ruby objects authored as part
    # of the plugin must have a foreign (Java) representation with which
    # they can wander about the Jenkins universe and possibly interact
    # with other foreign objects and APIs. Also, Foreign objects
    # coming in from Jenkins at large should be wrapped, where possible
    # to present an idomatic interface..
    #
    # Finally, Native plugin that had been wrapped and are comping home
    # must be unwrapped from their external form.
    #
    # For all cases, we want to maintain referential integrety so that
    # the same object always uses the same external form, etc... so
    # there is one instance of the `Proxies` class per plugin which will
    # reuse mappings where possible.
    class Proxies

      def initialize(plugin)
        @plugin = plugin
        @int2ext = java.util.WeakHashMap.new
        @ext2int = java.util.WeakHashMap.new
      end

      # Reflect a foreign Java object into the context of this plugin.
      #
      # If the object is a native plugin object that had been previously
      # exported, then it will unwrapped.
      #
      # Otherwise, we try to choose the best idiomatic API object for
      # this foreign object
      #
      # @param [Object] object the object to bring in from the outside
      # @return the best representation of that object for this plugin
      def import(object)
        if ref = @ext2int[object]
          return ref.get() if ref.get()
        end
        cls = object.class
        while cls do
          if internal_class = @@extcls2intcls[cls]
            internal = internal_class.new(object)
            link(internal, object)
            return internal
          end
          cls = cls.superclass
        end
        internal = NativeJavaObject.new(object)
        link(internal, object)
        return internal
      end

      # Reflect a native Ruby object into its External Java form.
      #
      # Try to find a suitable form for this object and if one is found then decorate it.
      # @param [Object] object the ruby object that is being exported to Java
      # @return [java.lang.Object] the Java wrapper that provides an interface to `object`
      # @throw [ExportError] if no suitable Java representation can be found
      def export(object)
        if ref = @int2ext[object]
          return ref.get() if ref.get()
        end

        cls = object.class
        while cls do
          if proxy_class = @@intcls2extcls[cls]
            proxy = proxy_class.new(@plugin, object)
            link(object, proxy)
            return proxy
          end
          cls = cls.superclass
        end
        raise ExportError, "unable to find suitable Java Proxy for #{object.inspect}"
      end

      ##
      # Link a plugin-local Ruby object to an external Java object such that they will
      # be subsituted for one another when passing values back and forth between Jenkins
      # and this plugin. An example of this is associating the Ruby Jenkins::Launcher object
      # with an equivalent
      #
      # @param [Object] internal the object on the Ruby side of the link
      # @param [java.lang.Object] external the object on the Java side of the link
      def link(internal, external)
        @int2ext.put(internal, java.lang.ref.WeakReference.new(external))
        @ext2int.put(external, java.lang.ref.WeakReference.new(internal))
      end

      ##
      # Associated the the Ruby class `internal_class` with the Java class `external_class`.
      #
      # Whenever a plugin is importing or exporting an object to the other side, it will first
      # see if there is an instance already linked. If not, it will try to create the other side
      # of the link by constructing it via reflection. `register` links two classes together so
      # that links can be built automatically.
      #
      # @param [Class] internal_class the Ruby class
      # @param [java.lang.Class] external_class the Java class on the othe side of this link.
      def self.register(internal_class, external_class)
        @@intcls2extcls[internal_class] = external_class
        @@extcls2intcls[external_class] = internal_class
      end

      ##
      # Remove all class linkages. This is mainly for testing purposes.
      def self.clear
        @@intcls2extcls = {}
        @@extcls2intcls = {}
      end
      clear
    end
  end
end

require 'jenkins/model/describable'
["action", "build_wrapper", "builder", "root_action"].each do |proxy|
  require "jenkins/plugin/proxies/#{proxy}"
end
