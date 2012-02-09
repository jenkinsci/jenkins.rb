require 'jenkins/tasks/build_step'

module Jenkins
  module Tasks
    ##
    # A single build step that run after the build is complete
    #
    # See BuildStep to see interface definitions.
    class Publisher
      include Jenkins::Model
      include Jenkins::Model::Describable

      include BuildStep

      describe_as Java.hudson.tasks.Publisher
    end
  end
end
