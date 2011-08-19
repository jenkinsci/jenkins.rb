
module Jenkins
  module Model

    module Included
      def included(cls)
        super(cls)
        if cls.class == Module
          cls.extend(Included)
        else
          cls.extend(ClassMethods)
          cls.send(:include, InstanceMethods)
        end
      end
    end
    extend Included

    module InstanceMethods
      # Get the display name of this Model. This value will be used as a default
      # whenever this model needs to be shown in the UI. If no display name has
      # been set, then it will use the Model's class name.
      #
      # @return [String] the display name
      def display_name
        self.class.display_name
      end
    end

    module ClassMethods

      # Set or get the display name of this Model Class.
      #
      # If `name` is not nil, then sets the display name.
      # @return [String] the display name
      def display_name(name = nil)
        name.nil? ? @display_name || self.name : @display_name = name.to_s
      end

      # Mark a set of properties that should not be persisted as part of this Model's lifecycle.
      #
      # Jenkins supports transparent persistent
      def transient(*properties)
        properties.each do |p|
          transients[p.to_sym] = true
        end
      end

      def transient?(property)
        transients.keys.member?(property.to_sym) || (superclass < Model && superclass.transient?(property))
      end

      def transients
        @transients ||= {}
      end
    end
  end
end
