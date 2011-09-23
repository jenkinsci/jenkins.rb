
require 'jenkins/tasks/builder'

module Jenkins
  class Plugin
    class Proxies
      class Builder < Java.hudson.tasks.Builder
        include Java.jenkins.ruby.Get
        include Jenkins::Plugin::Proxy

        def prebuild(build, listener)
          boolean_result(listener) do
            @object.prebuild(import(build), import(listener))
          end
        end

        def perform(build, launcher, listener)
          boolean_result(listener) do
            @object.perform(import(build), import(launcher), import(listener))
          end
        end

        def getDescriptor
          @plugin.descriptors[@object.class]
        end

        def get(name)
          @object.respond_to?(name) ? @object.send(name) : nil
        end

      private

        def boolean_result(listener, &block)
          begin
            yield
            true
          rescue Exception => e
            msg = "# e.message} (#{e.class})\n" << (e.backtrace || []).join("\n")
            listener.log(msg + "\n")
            false
          end
        end
      end

      register Jenkins::Tasks::Builder, Builder
    end
  end
end
