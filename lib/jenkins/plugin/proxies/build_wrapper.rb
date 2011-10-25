
require 'jenkins/tasks/build_wrapper'
require 'jenkins/model/build'

module Jenkins
  class Plugin
    class Proxies

      ##
      # Binds the Java hudson.tasks.BuildWrapper API to the idomatic
      # Ruby API Jenkins::Tasks::BuildWrapper

      class BuildWrapper < Java.hudson.tasks.BuildWrapper
        include Java.jenkins.ruby.Get
        include Jenkins::Plugin::Proxy

        def setUp(build, launcher, listener)
          env = {}
          begin
            @object.setup(import(build), import(launcher), import(listener), env)
          rescue Jenkins::Model::HaltError
            nil
          else
            EnvironmentWrapper.new(self, @plugin, @object, env)
          end
        end

        def getDescriptor
          @plugin.descriptors[@object.class]
        end

        def get(name)
          @object.respond_to?(name) ? @object.send(name) : nil
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
