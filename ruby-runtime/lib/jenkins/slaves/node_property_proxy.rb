module Jenkins::Slaves
  class NodePropertyProxy < Java.hudson.slaves.NodeProperty
    include Jenkins::Model::EnvironmentProxy
    include Jenkins::Model::DescribableProxy
    proxy_for NodeProperty
  end
end
