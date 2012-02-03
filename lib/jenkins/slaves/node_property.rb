module Jenkins::Slaves
  class NodeProperty
    include Jenkins::Model
    include Jenkins::Model::Describable

    def can_take?(buildable)
    end

    def setup(build, launcher, listener)
    end

    def teardown(build, listener)
    end

    class NodePropertyDescriptor < Java.hudson.slaves.NodePropertyDescriptor
      include Jenkins::Model::RubyDescriptor

      def isApplicable(targetType)
        true
      end
    end
    describe_as Java.hudson.slaves.NodeProperty, :with => NodePropertyDescriptor
  end
end