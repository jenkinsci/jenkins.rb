
require 'jenkins/tasks/build_wrapper'

module Jenkins
  module Plugins
    class Proxies

      ##
      # Binds the Java hudson.tasks.BuildWrapper API to the idomatic
      # Ruby API Jenkins::Tasks::BuildWrapper

      class BuildWrapper < Java.hudson.tasks.BuildWrapper
        include Java.jenkins.ruby.Get

        def initialize(plugin, object)
          super()
          @plugin = plugin
          @object = object
        end

        def setUp(build, launcher, listener)
          env = {}
          @object.setup(import(build), import(launcher), import(listener), env)
          EnvironmentWrapper.new(self, @plugin, @object, env)
        end

        def getDescriptor
          @plugin.descriptors[@object.class]
        end

        def get(name)
          @object.respond_to?(name) ? @object.send(name) : nil
        end

        private

        def import(object)
          @plugin.import(object)
        end

      end


      class EnvironmentWrapper < Java.hudson.tasks.BuildWrapper::Environment

        def initialize(build_wrapper, plugin, impl, env)
          super(build_wrapper)
          @plugin = plugin
          @impl = impl
          @env = env
        end

        def tearDown(build, listener)
          @impl.teardown(@plugin.import(build), @plugin.import(listener), @env)
        end
      end

      register Jenkins::Tasks::BuildWrapper, BuildWrapper
    end
  end
end
