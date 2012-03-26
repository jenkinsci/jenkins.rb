module Jenkins::Tasks
  class BuilderProxy < Java.hudson.tasks.Builder
    include BuildStepProxy
    proxy_for Jenkins::Tasks::Builder
  end
end