require 'jenkins/plugin/proxy'

module Jenkins
  class Plugin
    class Proxies
      # mix-in on top of the subtypes of the Describable Java class
      # to add standard behaviour as a proxy to Ruby object
      module Describable
        include Java.jenkins.ruby.Get
        include Jenkins::Plugin::Proxy

        def getDescriptor
          @plugin.descriptors[@object.class]
        end

        def get(name)
          @object.respond_to?(name) ? @object.send(name) : nil
        end
      end
    end
  end
end
