require 'jenkins/tasks/builder'
require 'jenkins/plugin/proxies/build_step'

module Jenkins
  class Plugin
    class Proxies
      class Builder < Java.hudson.tasks.Builder
        include Jenkins::Plugin::Proxies::Describable
        include Java.jenkins.ruby.Get
        include Jenkins::Plugin::Proxy
        include BuildStep
      end

      register Jenkins::Tasks::Builder, Builder
    end
  end
end
