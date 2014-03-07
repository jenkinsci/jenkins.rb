
module ProxyHelper

  def self.included(mod)
    super
    mod.class_eval do
      before do
        @plugin = double(Jenkins::Plugin, :name => "test-plugin", :linkout => true)

        @jBuild = double(Java.hudson.model.AbstractBuild)
        @jLauncher = double(Java.hudson.Launcher)
        @jListener = double(Java.hudson.model.BuildListener)

        @build = double(Jenkins::Model::Build)
        @launcher = double(Jenkins::Launcher)
        @listener = double(Jenkins::Model::Listener)

        @plugin.stub(:import).with(@jBuild).and_return(@build)
        @plugin.stub(:import).with(@jLauncher).and_return(@launcher)
        @plugin.stub(:import).with(@jListener).and_return(@listener)
      end
    end
  end
end
