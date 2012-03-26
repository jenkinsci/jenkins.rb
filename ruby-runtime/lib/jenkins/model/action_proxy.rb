
module Jenkins::Model
  module ActionProxy
    include Jenkins::Plugin::Proxy
    implemented do |cls|
      cls.class_eval do
        include Java.hudson.model.Action
      end
    end

    def getDisplayName
      @object.display_name
    end

    def getIconFileName
      @object.icon
    end

    def getUrlName
      @object.url_path
    end
  end
end
