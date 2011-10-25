require 'jenkins/filepath'

module Jenkins
  module Model
    # Raised to indicate that a build wrapper halted a build.
    # Raising this does *not* set the build result to error.
    class HaltError < Exception; end

    ##
    # Represents a single build. In general, you won't need this
    #
    class Build

      # the Hudson::Model::AbstractBuild represented by this build
      attr_reader :native

      def initialize(native = nil)
        @native = native
      end

      def workspace
        FilePath.new(@native.getWorkspace())
      end

      def halt(reason = nil)
        raise HaltError.new(reason)
      end

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
