require 'jenkins/tasks/publisher'
require 'jenkins/plugin/proxies/build_step'

module Jenkins
  class Plugin
    class Proxies
      class Publisher < Java.hudson.tasks.Publisher
        include BuildStep
        proxy_for Jenkins::Tasks::Publisher
      end
    end
  end
end
