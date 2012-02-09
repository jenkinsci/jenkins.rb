require 'jenkins/tasks/builder'
require 'jenkins/plugin/proxies/build_step'

module Jenkins
  class Plugin
    class Proxies
      class Builder < Java.hudson.tasks.Builder
        include BuildStep
        proxy_for Jenkins::Tasks::Builder
      end
    end
  end
end
