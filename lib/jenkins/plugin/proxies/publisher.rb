require 'jenkins/tasks/publisher'
require 'jenkins/plugin/proxies/build_step'

module Jenkins
  class Plugin
    class Proxies
      class Publisher < Java.hudson.tasks.Publisher
        include Jenkins::Plugin::Proxies::Describable
        include Java.jenkins.ruby.Get
        include Jenkins::Plugin::Proxy
        include BuildStep
      end

      register Jenkins::Tasks::Publisher, Publisher
    end
  end
end
