require 'spec_helper'
require 'jenkins/model/action'
describe Jenkins::Model::Action do

  it "has the same display_name semantics as Model" do
    a = new_action do
      display_name "CoolAction"
    end
    a.display_name.should eql "CoolAction"
  end

  describe "its icon_file" do
    it "is nil by default" do
      new_action.icon.should be_nil
    end
    it "can be configured" do
      action = new_action do
        icon "foo.png"
      end
      action.new.icon.should == "foo.png"
    end
  end

  describe "url_name" do
    it "can be configured"
  end

  private

  def new_action(&body)
    action = Class.new
    action.send(:include, Jenkins::Model::Action)
    action.class_eval(&body) if block_given?
    return action
  end
end
