require 'spec_helper'

describe Jenkins::Model::RootActionProxy do
  include ProxyHelper

  before do
    @object = mock(Jenkins::Model::RootActionProxy)
    @root_action = Jenkins::Model::RootActionProxy.new(@plugin, @object)
  end

  describe "getDisplayName" do
    it "calls through to its implementation" do
      @object.should_receive(:display_name)
      @root_action.getDisplayName
    end
  end

  describe "getIconFileName" do
    it "calls through to its implementation" do
      @object.should_receive(:icon)
      @root_action.getIconFileName
    end
  end

  describe "getUrlName" do
    it "calls through to its implementation" do
      @object.should_receive(:url_path)
      @root_action.getUrlName
    end
  end
end
