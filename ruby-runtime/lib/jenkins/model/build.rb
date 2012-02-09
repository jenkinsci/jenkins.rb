require 'jenkins/filepath'

module Jenkins
  module Model

    # Represents a single build. This object is passed in to
    # all build steps, and can be used to configure, halt, message
    # the current running build.
    class Build
      include Jenkins::Plugin::Wrapper

      wrapper_for Java.hudson.model.AbstractBuild

      # Raised to indicate that a build wrapper halted a build.
      # Raising this does *not* set the build result to error.
      class Halt < Exception; end

      # Hash of environment variables that will be added to each process
      # started as part of this build. E.g.
      #
      # build.env['GEM_HOME'] = '/path/to/my/gem/home'
      #
      # Note that this is not an exhaustive list of all environment variables,
      # only those which have been explicitly set by code inside this Ruby
      # plugin.
      #
      # Also, this list does not contain variables that might get set by things
      # like .profile and .rc files.
      attr_reader :env

      def initialize(native)
        super(native)
        @variables = {}
        @env = {}
        @native.buildEnvironments.add(EnvironmentVariables.new(@env))
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

      # The workspace associated with this build
      # @return [Jenkins::FilePath] workspace
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

      class EnvironmentVariables < Java.hudson.model.Environment
        def initialize(variables)
          super()
          @variables = variables
        end

        def buildEnvVars(map)
          @variables.each do |key,value|
            map.put(key.to_s.upcase, value.to_s)
          end
        end
      end

      # Until the accessor gets into mainline, we
      # add directly to the protected field
      # @see https://github.com/jenkinsci/jenkins/commit/8cd23888b4f07efaa5bb499ad599375ca67b9146
      Java.hudson.model.AbstractBuild.class_eval do
        field_accessor :buildEnvironments
      end

      Jenkins::Plugin::Proxies.register self, Java.hudson.model.AbstractBuild
    end

  end
end
