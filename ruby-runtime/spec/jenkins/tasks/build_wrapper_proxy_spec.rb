
require 'spec_helper'

describe Jenkins::Tasks::BuildWrapperProxy do
  include ProxyHelper

  subject {Jenkins::Tasks::BuildWrapperProxy}
  it {should be_transient(:plugin)}

  before do
    @object = double(Jenkins::Tasks::BuildWrapper)
    @wrapper = Jenkins::Tasks::BuildWrapperProxy.new(@plugin, @object)
  end

  it "passes in an env file which will be called to " do
    env = nil
    expect(@object).to receive(:setup).with(@build, @launcher, @listener) do |*args|
      env = args.last
    end
    environment = @wrapper.setUp(@jBuild, @jLauncher, @jListener)

    expect(@object).to receive(:teardown).with(@build, @listener)
    environment.tearDown(@jBuild, @jListener)
  end

  describe "halting behavior" do
    before do
      allow(@object).to receive(:setup).and_raise(Jenkins::Model::Build::Halt)
    end

    it "returns false if the build was halted explicitly" do
      expect(@wrapper.setUp(@jBuild, @jLauncher, @jListener)).to be_nil
    end
  end

  describe "halting behavior on teardown" do
    environment = nil
    before do
      allow(@object).to receive(:teardown).and_raise(Jenkins::Model::Build::Halt)
      allow(@object).to receive(:setup)
      environment = @wrapper.setUp(@jBuild, @jLauncher, @jListener)
    end

    it "returns false if the build was halted explicitly" do
      expect(environment.tearDown(@jBuild, @jListener)).to be_false
    end
  end

  describe "normal behavior on teardown" do
    environment = nil
    before do
      allow(@object).to receive(:teardown).and_return(nil)
      allow(@object).to receive(:setup)
      environment = @wrapper.setUp(@jBuild, @jLauncher, @jListener)
    end

    it "returns true if the build was not halted explicitly" do
      expect(environment.tearDown(@jBuild, @jListener)).to be_true
    end
  end
end
