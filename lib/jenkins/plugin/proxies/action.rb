require 'jenkins/model/action'
require 'jenkins/plugin/proxies/describable'

module Jenkins
  class Plugin
    class Proxies
      class Action
        include Java.hudson.model.Action
        include Jenkins::Plugin::Proxies::Describable

        def getIconFileName
          @object.icon
        end

        def getUrlName
          @object.url_path
        end
      end

      register Jenkins::Model::Action, Action
    end
  end
end
