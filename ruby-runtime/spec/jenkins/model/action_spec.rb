require 'spec_helper'

describe Jenkins::Model::Action do

  it "has the same display_name semantics as Model" do
    a = new_action do
      display_name "CoolAction"
    end
    expect(a.display_name).to eql "CoolAction"
  end

  describe "its icon_filename" do
    it "is nil by default" do
      expect(new_action.icon).to be_nil
    end
    it "can be configured" do
      action = new_action do
        icon "foo.png"
      end
      expect(action.new.icon).to eq("foo.png")
    end
  end

  describe "url_path" do
    it "is nil by default" do
      expect(new_action.url_path).to be_nil
    end
    it "can be configured" do
      expect(new_action do
        url_path "/foo/bar"
      end.new.url_path).to eql "/foo/bar"
    end
  end

  private

  def new_action(&body)
    action = Class.new
    action.send(:include, Jenkins::Model::Action)
    action.class_eval(&body) if block_given?
    return action
  end
end
