module Jenkins::Model
  module EnvironmentProxy
    extend Jenkins::Plugin::Behavior
    include Jenkins::Extension

    module InstanceMethods
      def setUp(build, launcher, listener)
        @object.setup(import(build), import(launcher), import(listener))
        environment_class = self.class.environment_class || DefaultEnvironment
        environment_class.new(self, @plugin, @object).tap do |env|
          env.plugin = @plugin
          env.impl = @object
        end
      rescue Jenkins::Model::Build::Halt
        nil
      end
    end

    module ClassMethods
      attr_reader :environment_class

      def environment_is(java_class, &block)
        @environment_class = Class.new(java_class)
        if block_given?
          @environment_class.class_eval(&block)
        end
        @environment_class.class_eval do
          include EnvironmentWrapper
        end
      end
    end

    module EnvironmentWrapper
      attr_accessor :plugin, :impl

      def tearDown(build, listener)
        @impl.teardown(@plugin.import(build), @plugin.import(listener))
        true
      rescue Jenkins::Model::Build::Halt
        false
      end
    end

    class DefaultEnvironment < Java.hudson.model.Environment
      include EnvironmentWrapper
      def initialize(proxy, plugin, object)
        super()
        @plugin = plugin
        @object = object
      end
    end

  end
end