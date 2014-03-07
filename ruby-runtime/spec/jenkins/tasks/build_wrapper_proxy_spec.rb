
require 'spec_helper'

describe Jenkins::Tasks::BuildWrapperProxy do
  include ProxyHelper

  subject {Jenkins::Tasks::BuildWrapperProxy}
  it {should be_transient(:plugin)}

  before do
    @object = mock(Jenkins::Tasks::BuildWrapper)
    @wrapper = Jenkins::Tasks::BuildWrapperProxy.new(@plugin, @object)
  end

  it "passes in an env file which will be called to " do
    env = nil
    @object.should_receive(:setup).with(@build, @launcher, @listener) do |*args|
      env = args.last
    end
    environment = @wrapper.setUp(@jBuild, @jLauncher, @jListener)

    @object.should_receive(:teardown).with(@build, @listener)
    environment.tearDown(@jBuild, @jListener)
  end

  describe "halting behavior" do
    before do
      @object.stub(:setup).and_raise(Jenkins::Model::Build::Halt)
    end

    it "returns false if the build was halted explicitly" do
      @wrapper.setUp(@jBuild, @jLauncher, @jListener).should be_nil
    end
  end

  describe "halting behavior on teardown" do
    environment = nil
    before do
      @object.stub(:teardown).and_raise(Jenkins::Model::Build::Halt)
      @object.stub(:setup)
      environment = @wrapper.setUp(@jBuild, @jLauncher, @jListener)
    end

    it "returns false if the build was halted explicitly" do
      environment.tearDown(@jBuild, @jListener).should be_false
    end
  end

  describe "normal behavior on teardown" do
    environment = nil
    before do
      @object.stub(:teardown).and_return(nil)
      @object.stub(:setup)
      environment = @wrapper.setUp(@jBuild, @jLauncher, @jListener)
    end

    it "returns true if the build was not halted explicitly" do
      environment.tearDown(@jBuild, @jListener).should be_true
    end
  end
end
