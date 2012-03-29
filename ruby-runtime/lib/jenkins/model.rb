module Jenkins
  module Model
    extend Plugin::Behavior
    include Jenkins::Extension

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

    module ClassMethods
      include ClassDisplayName
      include Transience
    end

    module InstanceMethods
      include InstanceDisplayName
    end
  end
end

require 'jenkins/model/descriptor'
require 'jenkins/model/describable'
require 'jenkins/model/describable_native'
require 'jenkins/model/describable_proxy'
require 'jenkins/model/environment'
require 'jenkins/model/environment_proxy'
require 'jenkins/model/action'
require 'jenkins/model/action_proxy'
require 'jenkins/model/root_action'
require 'jenkins/model/root_action_proxy'
require 'jenkins/model/build'
require 'jenkins/model/listener'
