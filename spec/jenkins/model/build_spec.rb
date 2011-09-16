require 'spec_helper'

describe Jenkins::Model::Build do

  it "can be instantiated" do
    Jenkins::Model::Build.new(mock(Java.hudson.model.AbstractBuild))
  end

  # TODO: spec for build_var and env
  # Just a mocking and method invocation checks are enough?
end
