require 'spec_helper'

describe Jenkins::Plugin do
  it "is unbelievable that I don't have a spec for this class" do
    Jenkins::Plugin.instance_method(:initialize).should_not be_nil
  end
end
