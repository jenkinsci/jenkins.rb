module Jenkins
  module Tasks
    module BuildStep
      ##
      # Runs before the build begins
      #
      # @param [Jenkins::Model::Build] build the build which will begin
      # @param [Jenkins::Model::Listener] listener the listener for this build.
      def prebuild(build, listener)
      end

      ##
      # Runs the step over the given build and reports the progress to the listener.
      #
      # @param [Jenkins::Model::Build] build on which to run this step
      # @param [Jenkins::Launcher] launcher the launcher that can run code on the node running this build
      # @param [Jenkins::Model::Listener] listener the listener for this build.
      def perform(build, launcher, listener)
      end

      ##
      # @param [Jenkins::Model::Project]
      # @return [Array<?>]
      #def project_actions(project)
      #end

      ##
      # @param [Jenkins::Model::Project]
      # @return [?]
      def project_action(project)
      end
    end
  end
end
