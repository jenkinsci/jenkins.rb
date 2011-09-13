
module Jenkins
  module Tasks
    ##
    # A single step in the entire build process
    class Builder
      include Jenkins::Model
      include Jenkins::Model::Describable

      describe_as Java.hudson.tasks.Builder

      ##
      # Runs before the build begins
      #
      # @param [Jenkins::Model::Build] build the build which will begin
      # @param [Jenkins::Launcher] launcher the launcher that can run code on the node running this build
      # @param [Jenkins::Model::Listener] listener the listener for this build.
      # @return `true` if this build can continue or `false` if there was an error
      # and the build needs to be aborted
      def prebuild(build, launcher, listener)

      end

      ##
      # Runs the step over the given build and reports the progress to the listener.
      #
      # @param [Jenkins::Model::Build] build on which to run this step
      # @param [Jenkins::Launcher] launcher the launcher that can run code on the node running this build
      # @param [Jenkins::Model::Listener] listener the listener for this build.
      # return `true if this build can continue or `false` if there was an error
      # and the build needs to be aborted
      def perform(build, launcher, listener)

      end
    end
  end
end
