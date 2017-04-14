require 'spec_helper'
require 'jenkins/model/health_reporting_action'

describe Jenkins::Model::HealthReportingActionProxy do
  include ProxyHelper

  subject do
    Jenkins::Model::HealthReportingActionProxy.new(@plugin, @object)
  end

  before do
    @object = mock(Jenkins::Model::HealthReportingActionProxy)
  end

  describe "#getDisplayName" do
    it "calls through to its implementation" do
      @object.should_receive(:display_name)
      subject.getDisplayName
    end
  end

  describe "#getIconFileName" do
    it "calls through to its implementation" do
      @object.should_receive(:icon)
      subject.getIconFileName
    end
  end

  describe "#getUrlName" do
    it "calls through to its implementation" do
      @object.should_receive(:url_path)
      subject.getUrlName
    end
  end

  describe "#getBuildHealth" do
    it "calls through to its implementation" do
      @object.should_receive(:build_health)
      subject.getBuildHealth
    end
  end
end
