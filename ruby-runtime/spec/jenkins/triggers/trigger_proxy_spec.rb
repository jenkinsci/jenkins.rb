require 'spec_helper'

describe Jenkins::Triggers::TriggerProxy do
  include ProxyHelper

  before do
    @object = double(Jenkins::Triggers::Trigger)
    @builder = Jenkins::Triggers::TriggerProxy.new(@plugin, @object)
  end

  describe "run" do
    it "calls through to its implementation" do
      expect(@object).to receive(:run)
      @builder.run
    end
  end

  describe "stop" do
    it "calls through to its implementation" do
      expect(@object).to receive(:stop)
      @builder.stop
    end
  end
end
