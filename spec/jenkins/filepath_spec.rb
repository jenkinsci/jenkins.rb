require 'spec_helper'

describe Jenkins::FilePath do

  it "can be instantiated" do
    Jenkins::FilePath.new(mock(Java.hudson.FilePath))
  end

  # TODO: spec for methods
end

