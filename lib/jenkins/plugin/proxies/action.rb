require 'jenkins/model/action'

module Jenkins
  class Plugin
    class Proxies
      class Action
        include Java.hudson.model.Action
        include Java.jenkins.ruby.Get
        include Jenkins::Plugin::Proxy

        def getIconFileName
          @object.icon
        end

        def getUrlName
          @object.url_path
        end

        def getDescriptor
          @plugin.descriptors[@object.class]
        end

        def get(name)
          @object.respond_to?(name) ? @object.send(name) : nil
        end
      end

      register Jenkins::Model::Action, Action
    end
  end
end
