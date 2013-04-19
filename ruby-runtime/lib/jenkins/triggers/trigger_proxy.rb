module Jenkins::Triggers
  class TriggerProxy < Java.hudson.triggers.Trigger
    include Jenkins::Model::DescribableProxy
    proxy_for Jenkins::Triggers::Trigger

    def run
      @object.run
    end

    def stop
      @object.stop
    end
  end
end