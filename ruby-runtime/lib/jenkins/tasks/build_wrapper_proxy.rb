module Jenkins::Tasks
  class BuildWrapperProxy < Java.hudson.tasks.BuildWrapper
    include Jenkins::Plugin::Proxies::Describable
    proxy_for Jenkins::Tasks::BuildWrapper

    include Jenkins::Model::EnvironmentProxy

    # BuildWrapper needs a custom Environment class, not sure why
    environment_is Java.hudson.tasks.BuildWrapper::Environment do
      def initialize(proxy, plugin, object)
        super(proxy)
      end
    end
  end
end