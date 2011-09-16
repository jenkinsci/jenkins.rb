
require 'jenkins/tasks/builder'

module Jenkins
  class Plugin
    class Proxies
      class Builder < Java.hudson.tasks.Builder
        include Java.jenkins.ruby.Get
        include Jenkins::Plugin::Proxy

        def prebuild(build, listener)
          @object.prebuild(import(build), import(listener)) ? true : false
        end

        def perform(build, launcher, listener)
          @object.perform(import(build), import(launcher), import(listener)) ? true : false
        end

        def getDescriptor
          @plugin.descriptors[@object.class]
        end

        def get(name)
          @object.respond_to?(name) ? @object.send(name) : nil
        end

      end

      register Jenkins::Tasks::Builder, Builder
    end
  end
end
