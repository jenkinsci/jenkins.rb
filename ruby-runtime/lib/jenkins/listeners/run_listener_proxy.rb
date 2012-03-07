module Jenkins::Listeners
  class RunListenerProxy < Java.hudson.model.listeners.RunListener
    include Jenkins::Plugin::Proxy

    def initialize(plugin, object)
      super(plugin, object, Java.hudson.model.AbstractBuild.java_class)
    end

    def onStarted(run, listener)
      @object.started(run, listener)
    end

    def onCompleted(run, listener)
      @object.completed(run, listener)
    end

    def onFinalized(run)
      @object.finalized(run)
    end

    def onDeleted(run)
      @object.deleted(run)
    end
  end
end