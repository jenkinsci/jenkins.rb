
require 'jenkins/model'

module Jenkins
  module Model

    # TODO: I turned Action into Class from Module but it should be a bad idea.
    # The change may be reverted. I used class Action for implementing a model
    # as a describable but I really should do is implementing describable.
    class Action
      include Model

      module InstanceMethods
        def icon
          self.class.icon
        end

        def url_path
          self.class.url_path
        end
      end

      module ClassMethods
        def icon(filename = nil)
          filename.nil? ? @icon : @icon = filename.to_s
        end

        def url_path(path = nil)
          path.nil? ? @url_path : @url_path = path.to_s
        end
      end

      include InstanceMethods
      extend ClassMethods
    end
  end
end
