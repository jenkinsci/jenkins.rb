require 'spec_helper'

describe Jenkins::Tasks::BuilderProxy do
  include ProxyHelper

  before do
    @object = mock(Jenkins::Tasks::Builder)
    @builder = Jenkins::Tasks::BuilderProxy.new(@plugin, @object)
  end

  describe "prebuild" do
    it "calls through to its implementation" do
      @object.should_receive(:prebuild).with(@build, @listener)
      @builder.prebuild(@jBuild, @jListener)
    end

    it "returns true whatever Ruby side impl returns" do
      @object.should_receive(:prebuild).and_return(false)
      @builder.prebuild(@jBuild, @jListener).should == true
    end

    it "returns false when Ruby side impl raise an Error" do
      @object.should_receive(:prebuild).and_raise(NoMethodError)
      @jListener.should_receive(:error)
      @builder.prebuild(@jBuild, @jListener).should == false
    end
  end

  describe "perform" do
    it "calls through to its implementation" do
      @object.should_receive(:perform).with(@build, @launcher, @listener)
      @builder.perform(@jBuild, @jLauncher, @jListener)
    end
  end
end
