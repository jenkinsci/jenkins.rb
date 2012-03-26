module Jenkins
  module Tasks
    ##
    # A single build step in the entire build process
    #
    # See BuildStep to see interface definitions.
    class Builder
      include Jenkins::Model
      include Jenkins::Model::Describable

      include BuildStep

      describe_as Java.hudson.tasks.Builder
    end
  end
end
