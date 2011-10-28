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
        @variables = {}
      end

      # Gets a build value. Each build stores a map of key,value
      # pairs which can be used by each build step in the pipeline
      #
      # @param [String|Symbol] key
      # @return [Object] value
      def [](key)
        @variables[key.to_s]
      end

      # Sets a build value. Each build has a map of key,value
      # pairs which allow build steps to share information
      #
      # @param [String|Symbol] key
      # @param [Object] value
      # @return [Object] value
      def []=(key, value)
        @variables[key.to_s] = value
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

      def build_wrapper_environment(cls)
        @native.getEnvironmentList().find do |e|
          e.instance_of?(Jenkins::Plugin::Proxies::EnvironmentWrapper) && e.build_wrapper.instance_of?(cls)
        end
      end

      Jenkins::Plugin::Proxies.register self, Java.hudson.model.AbstractBuild
    end

  end
end
