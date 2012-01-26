require 'jenkins/tasks/builder'
require 'jenkins/plugin/proxies/build_step'

module Jenkins
  class Plugin
    class Proxies
      class Builder < Java.hudson.tasks.Builder
        include BuildStep
      end

      register Jenkins::Tasks::Builder, Builder
    end
  end
end
