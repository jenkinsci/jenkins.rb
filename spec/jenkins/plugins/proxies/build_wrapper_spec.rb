
require 'spec_helper'

describe Jenkins::Plugin::Proxies::BuildWrapper do
  include ProxyHelper

  before do
    @object = mock(Jenkins::Tasks::BuildWrapper)
    @wrapper = Jenkins::Plugin::Proxies::BuildWrapper.new(@plugin, @object)
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