
module Jenkins
  module Model

    # Register a Ruby class as a Jenkins extension point

    # When Jenkins is searching for all the extension points of a particular
    # type... let's say `Builder` for example. It first asks for all the `Descriptor`s
    # registered to describe the `Builder` type. It will then use the descriptors
    # it finds to do things like construct and validate the extension objects.
    #
    # It helps me to think about the Jenkins `Descriptor` as a Ruby class. It is a
    # factory for instances, and contains data about what those instances can do.
    #
    # This module, when included, provides a single class method `describe_as`
    # which tell Jenkins in effect "when you are looking for Java Classes of this type"
    # you can use this ruby class too. e.g.
    #
    #     class Builder
    #       include Jenkins::Model::Describable
    #       describe_as Java.hudson.tasks.Builder
    #       descriptor_is Jenkins::Tasks::BuildStepDescriptor
    #     end
    #
    # behind the scenes, this creates a `Descriptor` instance registered against the java type
    # `Java.hudson.tasks.Builder`. Now, any time Jenkins asks about what kind of `hudson.tasks.Builder`s there
    # are in the system, this class will come up.
    #
    # This class should generally not be needed by plugin authors since it is part of the
    # glue layer and not the public runtime API.
    module Describable
      extend Plugin::Behavior
      include Jenkins::Extension
      DescribableError = Class.new(StandardError)

      implemented do |cls|
        Jenkins.plugin.register_describable cls if Jenkins.plugin
      end

      module DescribeAs

        # Java class that represents the extension point, which gets eventually set to Descriptor.clazz
        # :with will use this java class as the type of descriptor.
        def describe_as cls, options = {}
          @describe_as_type = verify_java_class(cls)
          @descriptor_is = verify_java_class(options[:with]) if options[:with]
        end

        def describe_as_type
          @describe_as_type ? @describe_as_type : (superclass.describe_as_type if superclass.respond_to?(:describe_as_type)) || verify_java_class(self)
        end

        def descriptor_is
          @descriptor_is ? @descriptor_is : (superclass.descriptor_is if superclass.respond_to?(:descriptor_is)) || DefaultDescriptor
        end

        private

        def verify_java_class cls
          if !defined?(cls.java_class) || !cls.is_a?(Class)
            fail DescribableError, "#{cls.class.inspect} is not an instance of java.lang.Class"
          end
          cls
        end
      end

      module ClassMethods
        include DescribeAs
      end
    end
  end
end