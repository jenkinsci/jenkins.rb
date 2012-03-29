module Jenkins::Slaves
  class NodeProperty
    include Jenkins::Model
    include Jenkins::Model::Environment
    include Jenkins::Model::Describable

    class NodePropertyDescriptor < Java.hudson.slaves.NodePropertyDescriptor
      include Jenkins::Model::Descriptor

      def isApplicable(targetType)
        true
      end
    end
    describe_as Java.hudson.slaves.NodeProperty, :with => NodePropertyDescriptor
  end
end