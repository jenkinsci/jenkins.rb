require 'jenkins/model/root_action'

module Jenkins
  class Plugin
    class Proxies
      class RootAction
        include Action
        include Java.hudson.model.RootAction
        proxy_for Jenkins::Model::RootAction
      end
    end
  end
end
