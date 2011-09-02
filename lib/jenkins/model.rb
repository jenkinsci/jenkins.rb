
module Jenkins
  module Model

    module Included
      def included(cls)
        super(cls)
        if cls.class == Module
          cls.extend(Included)
        else
          cls.extend(Inherited)
          cls.extend(ClassDisplayName)
          cls.extend(Transience)
          cls.send(:include, InstanceDisplayName)
        end
        Model.descendant(cls)
      end
    end
    extend Included

    module Inherited
      def inherited(cls)
        super(cls)
        Model.descendant(cls)
        cls.extend(Inherited)
      end
    end

    module InstanceDisplayName
      # Get the display name of this Model. This value will be used as a default
      # whenever this model needs to be shown in the UI. If no display name has
      # been set, then it will use the Model's class name.
      #
      # @return [String] the display name
      def display_name
        self.class.display_name
      end
    end

    module ClassDisplayName

      # Set or get the display name of this Model Class.
      #
      # If `name` is not nil, then sets the display name.
      # @return [String] the display name
      def display_name(name = nil)
        name.nil? ? @display_name || self.name : @display_name = name.to_s
      end
    end

    module Transience

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

    module Descendants
      def descendant(mod)
        @descendants ||= clear
        @descendants[mod] = true
      end

      def descendants
        @descendants.keys
      end

      def clear
        @descendants = {}
      end

      def descendant?(cls)
        @descendants[cls]
      end
    end
    extend Descendants
  end
end
