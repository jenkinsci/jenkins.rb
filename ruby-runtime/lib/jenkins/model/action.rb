
module Jenkins
  module Model
    module Action
      include ::Jenkins::Model

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
    end
  end
end
