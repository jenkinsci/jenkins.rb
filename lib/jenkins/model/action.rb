
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

      # def included(cls)
      #   super(cls)
      #   cls.send(:include)
      # end
      module InstanceMethods
        def icon
          self.class.icon
        end
      end
      # 
      module ClassMethods
        def icon(path = nil)
          path.nil? ? @path : @path = path.to_s
        end
      end
    end
  end
end