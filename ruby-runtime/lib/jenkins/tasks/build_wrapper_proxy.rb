module Jenkins::Tasks
  class BuildWrapperProxy < Java.hudson.tasks.BuildWrapper
    include Jenkins::Model::DescribableProxy
    include Jenkins::Model::EnvironmentProxy
    proxy_for Jenkins::Tasks::BuildWrapper

    # BuildWrapper needs a custom Environment class, not sure why
    environment_is Java.hudson.tasks.BuildWrapper::Environment do
      def initialize(proxy, plugin, object)
        super(proxy)
      end
    end
  end
end