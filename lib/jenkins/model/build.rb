require 'jenkins/filepath'

module Jenkins
  module Model
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

      def build_var
        @native.getBuildVariables()
      end

      def env(listener = nil)
        if listener
          # TODO: not tested. dump to listener?
          listener = Plugin.instance.export(listener)
        end
        @native.getEnvironment(listener)
      end

      Jenkins::Plugin::Proxies.register self, Java.hudson.model.AbstractBuild
    end

  end
end
