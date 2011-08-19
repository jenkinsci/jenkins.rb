require 'spec_helper'

describe Jenkins::Model::Build do

  it "can be instantiated" do
    Jenkins::Model::Build.new(mock(Java.hudson.model.AbstractBuild))
  end
end
