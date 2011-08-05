
require 'spec_helper'

describe Jenkins::Plugins::Proxies::BuildWrapper do

  before do
    @plugin = mock(Jenkins::Plugin)
    @object = mock(Jenkins::Tasks::BuildWrapper)
    @wrapper = Jenkins::Plugins::Proxies::BuildWrapper.new(@plugin, @object)

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

  it "passes in an env file which will be called to " do
    env = nil
    @object.should_receive(:setup).with(@build, @launcher, @listener, an_instance_of(Hash)) do |*args|
      env = args.last
    end
    environment = @wrapper.setUp(@jBuild, @jLauncher, @jListener)

    @object.should_receive(:teardown).with(@build, @listener, env)
    environment.tearDown(@jBuild, @jListener)
  end
end