module Jenkins::Tasks
  class PublisherProxy < Java.hudson.tasks.Publisher
    include BuildStepProxy
    proxy_for Jenkins::Tasks::Publisher
  end
end
