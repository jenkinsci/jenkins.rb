require 'set'

module Jenkins
  class Plugin
    # A Behavior will receive a callback any time that it is
    # included into a class or when a class that has been included
    # is extended. This is needed for a couple reasons.
    #
    # One case is to enable Transient marking behavior. Every
    # time a concrete model class is implemented, it needs the
    # ability to define which of its attributes are transient,
    # so that they will not be persisted with the Jenkins serialization.
    # which attributes are tracked on a per-class basis, so we
    # need a callback for each class in the inheritance hierachy.
    #
    # class Foo
    #  include Model
    #  transient :foo do
    #    @foo = 1 + 2
    #  end
    # end
    # class Bar < Foo
    #   transient :bar do # <- no need to include Model
    #     @bar = create_bar
    #   end
    # end
    #
    # Another is the case of auto registration. We want to be able
    # to find out when extension points are implemented, and register
    # them with the Jenkins Runtime
    #
    # module Descriptor
    #   implemented do |cls|
    #     Jenkins.plugin.on.start do |plugin|
    #       plugin.register_extension new(Jenkins.plugin, cls.ruby_type, cls.java_type)
    #     end
    #   end
    # end
    #
    # And of course, there is the case of proxies where we need to make sure that
    # certain behaviors are always included into the proxy, and that if java classes
    # need to be implemented, they are.
    #
    # If the module (=X) that extend Behavior defines a module named ClassMethods in it,
    # then every subtype of X automatically extends this ClassMethods.n
    #
    # module Foo
    #  extend Behavior
    #  module ClassMethod
    #    def look_ma
    #      puts "I'm here'"
    #    end
    #  end
    # end
    # class Bar
    #   include Foo
    # end
    #
    # Bar.look_ma
    #
    module Behavior
      def included(mod)
        if mod.is_a? Class
          mod.extend Implementation unless mod.is_a? Implementation
        else
          mod.extend Behavior unless mod.is_a? Behavior
        end
        mod.behaves_as *@_behaviors
        super(mod)
      end

      def implemented(cls = nil, &implemented_block)
        if cls
          @implemented_block.call cls if @implemented_block
        else
          @implemented_block = implemented_block
        end
      end

      def self.extended(mod)
        super(mod)
        mod.instance_eval do
          @_behaviors = Set.new([self])
        end
      end

      module BehavesAs
        def behaves_as(*behaviors)
          @_behaviors ||= Set.new
          behaviors.each do |b|
            unless @_behaviors.include? b
              self.extend b::ClassMethods if b.const_defined? :ClassMethods
              self.send(:include, b::InstanceMethods) if b.const_defined? :InstanceMethods
              b.implemented self if self.is_a? Class
              @_behaviors << b
            end
          end
          return @_behaviors
        end
      end
      include BehavesAs

      module Implementation
        include BehavesAs

        def inherited(cls)
          super.tap do
            cls.extend Implementation unless cls.is_a? Implementation
            cls.behaves_as *@_behaviors
          end
        end
      end
    end
  end
end
