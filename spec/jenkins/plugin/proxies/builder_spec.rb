require 'spec_helper'

describe Jenkins::Plugin::Proxies::Builder do
  include ProxyHelper

  before do
    @object = mock(Jenkins::Tasks::Builder)
    @builder = Jenkins::Plugin::Proxies::Builder.new(@plugin, @object)
  end

  describe "prebuild" do
    it "calls through to its implementation" do
      @object.should_receive(:prebuild).with(@build, @listener)
      @builder.prebuild(@jBuild, @jListener)
    end
  end

  describe "perform" do
    it "calls through to its implementation" do
      @object.should_receive(:perform).with(@build, @launcher, @listener)
      @builder.perform(@jBuild, @jLauncher, @jListener)
    end
  end
end
