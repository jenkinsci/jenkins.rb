require 'jenkins/tasks/publisher'
require 'jenkins/plugin/proxies/build_step'

module Jenkins
  class Plugin
    class Proxies
      class Publisher < Java.hudson.tasks.Publisher
        include BuildStep
      end

      register Jenkins::Tasks::Publisher, Publisher
    end
  end
end
