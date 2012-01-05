
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
      DescribableError = Class.new(StandardError)

      module DescribeAs
        # Java class that represents the extension point, which gets eventually set to Descriptor.clazz
        def describe_as cls
          @describe_as_type = verify_java_class(cls).java_class
        end
        attr_reader :describe_as_type

        # Java-Descriptor-subtype-subclassed-in-Ruby type that represents the class used to instantiate a Descriptor.
        def descriptor_is cls
          @descriptor_is = verify_java_class(cls)
        end

      private
        def verify_java_class cls
          if !defined?(cls.java_class) || !cls.is_a?(Class)
            fail DescribableError, "#{cls.class.inspect} is not an instance of java.lang.Class"
          end
          cls
        end
      end

      # When a Describable class is subclassed, make it also Describable
      module Inherited
        def inherited(cls)
          super(cls)
          cls.extend Inherited
          describe_as_type = @describe_as_type
          cls.class_eval do
            @describe_as_type = describe_as_type
          end
          descriptor_is = @descriptor_is
          cls.class_eval do
            @descriptor_is = descriptor_is
          end
          if Jenkins::Plugin.instance
            Jenkins::Plugin.instance.register_describable(cls, describe_as_type, descriptor_is)
          end
        end
      end

      module Included
        def included(mod)
          super
          if mod.is_a? Class
            mod.extend DescribeAs
            mod.extend Inherited
          else
            warn "tried to include Describable into a Module. Are you sure?"
          end
        end
      end
      self.extend Included
    end
  end
end