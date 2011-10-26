require 'jenkins/filepath'

module Jenkins
  module Model

    ##
    # Represents a single build. In general, you won't need this
    #
    class Build

      # Raised to indicate that a build wrapper halted a build.
      # Raising this does *not* set the build result to error.
      class Halt < Exception; end


      # the Hudson::Model::AbstractBuild represented by this build
      attr_reader :native

      def initialize(native = nil)
        @native = native
      end

      def workspace
        FilePath.new(@native.getWorkspace())
      end

      # Halt the current build, without setting the result to failure
      #
      # @param [String] reason the reason for your halt, optional.
      def halt(reason = nil)
        raise Halt, reason
      end

      # Abort the current build, causing a build failure.
      #
      # @param [String] reason the reason for your abort, optional.
      def abort(reason = nil)
        raise Java.hudson.AbortException.new(reason)
      end

      def build_var
        @native.getBuildVariables()
      end

      def env
        @native.getEnvironment(nil)
      end

      Jenkins::Plugin::Proxies.register self, Java.hudson.model.AbstractBuild
    end

  end
end
