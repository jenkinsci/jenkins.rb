require 'spec_helper'

describe Jenkins::Tasks::PublisherProxy do
  include ProxyHelper

  before do
    @object = double(Jenkins::Tasks::Publisher)
    @builder = Jenkins::Tasks::PublisherProxy.new(@plugin, @object)
  end

  describe "prebuild" do
    it "calls through to its implementation" do
      expect(@object).to receive(:prebuild).with(@build, @listener)
      @builder.prebuild(@jBuild, @jListener)
    end

    it "returns true whatever Ruby side impl returns" do
      expect(@object).to receive(:prebuild).and_return(false)
      expect(@builder.prebuild(@jBuild, @jListener)).to eq(true)
    end

    it "returns false when Ruby side impl raise an Error" do
      expect(@object).to receive(:prebuild).and_raise(NoMethodError)
      expect(@jListener).to receive(:error)
      expect(@builder.prebuild(@jBuild, @jListener)).to eq(false)
    end
  end

  describe "perform" do
    it "calls through to its implementation" do
      expect(@object).to receive(:perform).with(@build, @launcher, @listener)
      @builder.perform(@jBuild, @jLauncher, @jListener)
    end
  end
end
