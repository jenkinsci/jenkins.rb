
module ProxyHelper

  def self.included(mod)
    super
    mod.class_eval do
      before do
        @plugin = mock(Jenkins::Plugin, :name => "test-plugin", :linkout => true)

        @jBuild = mock(Java.hudson.model.AbstractBuild)
        @jLauncher = mock(Java.hudson.Launcher)
        @jListener = mock(Java.hudson.model.BuildListener)

        @build = mock(Jenkins::Model::Build)
        @launcher = mock(Jenkins::Launcher)
        @listener = mock(Jenkins::Model::Listener)

        @plugin.stub(:import).with(@jBuild).and_return(@build)
        @plugin.stub(:import).with(@jLauncher).and_return(@launcher)
        @plugin.stub(:import).with(@jListener).and_return(@listener)
      end
    end
  end
end
