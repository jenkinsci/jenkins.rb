module Jenkins
  module Model
    class Project
      include Jenkins::Plugin::Wrapper

      wrapper_for Java.hudson.model.AbstractProject

      def initialize(native)
        super(native)
      end

      def actions
        @native.getActions()
      end

      def icon_file_name
        @native.getIconFileName()
      end

      def search_url
        @native.getSearchUrl()
      end

      Jenkins::Plugin::Proxies.register self, Java.hudson.model.AbstractProject
    end
  end
end
