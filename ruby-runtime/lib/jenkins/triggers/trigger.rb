require 'jenkins/model'

module Jenkins
  module Triggers
    # Triggers a Build.
    # {http://javadoc.jenkins-ci.org/hudson/triggers/Trigger.html}
    class Trigger
      include Jenkins::Model
      include Jenkins::Model::Describable
      describe_as Java.hudson.triggers.Trigger, :with => Jenkins::Triggers::TriggerDescriptor

      # Executes the triggered task.
      #
      # This method is invoked when Trigger.new(String) is used
      # to create an instance, and the crontab matches the current time.
      def run
      end

      # Called before a Trigger is removed.
      # Under some circumstances, this may be invoked more than once for
      # a given Trigger, so be prepared for that.
      #
      # When the configuration is changed for a project, all triggers
      # are removed once and then added back.
      def stop
      end
    end
  end
end
