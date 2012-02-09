module Jenkins::Slaves
  class NodePropertyProxy < Java.hudson.slaves.NodeProperty
    include Jenkins::Model::EnvironmentProxy
    include Jenkins::Plugin::Proxies::Describable
    proxy_for NodeProperty
  end
end
