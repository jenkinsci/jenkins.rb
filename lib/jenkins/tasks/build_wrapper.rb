
require 'jenkins/model'

module Jenkins
  module Tasks
    # Decorate a build with pre and post hooks.
    # {http://javadoc.jenkins-ci.org/hudson/tasks/BuildWrapper.html}
    class BuildWrapper
      include Jenkins::Model
      include Jenkins::Model::Describable

      describe_as Java.hudson.tasks.BuildWrapper

      # Perform setup for a build
      #
      # invoked after checkout, but before any `Builder`s have been run
      # @param [Jenkins::Model::Build] build the build about to run
      # @param [Jenkins::Launcher] launcher a launcher for the orderly starting/stopping of processes.
      # @param [Jenkins::Model::Listener] listener channel for interacting with build output console
      # @param [Hash] env a place to store information needed by #teardown
      def setup(build, launcher, listener, env)

      end

      # Optionally perform optional teardown for a build
      #
      # invoked after a build has run for better or for worse. It's ok if subclasses
      # don't override this.
      #
      # @param [Jenkins::Model::Build] the build which has completed
      # @param [Jenkins::Model::Listener] listener channel for interacting with build output console
      # @param [Hash] env contains anything that #setup needs to tell #teardown about
      def teardown(build, listener, env)

      end
    end
  end
end
