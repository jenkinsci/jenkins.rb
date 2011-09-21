require 'jenkins/model/root_action'

module Jenkins
  class Plugin
    class Proxies
      class RootAction
        include Java.hudson.model.RootAction
        include Jenkins::Plugin::Proxy

        def getDisplayName
          @object.display_name
        end

        def getIconFileName
          @object.icon
        end

        def getUrlName
          @object.url_path
        end
      end

      register Jenkins::Model::RootAction, RootAction
    end
  end
end
