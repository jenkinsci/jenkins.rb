
#TODO: does this make more sense as a class? maybe

module Jenkins
  module Model
    module Action
      include Model

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
        def icon
          self.class.icon
        end

        def url_path
          self.class.url_path
        end
      end
      #
      module ClassMethods
        def icon(filename = nil)
          filename.nil? ? @icon : @icon = filename.to_s
        end

        def url_path(path = nil)
          path.nil? ? @url_path : @url_path = path.to_s
        end
      end
    end
  end
end