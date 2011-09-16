require 'spec_helper'

describe Jenkins::Plugin::Specification do

  it "is invalid by default" do
    expect {subject.validate!}.should raise_error Jenkins::Plugin::SpecificationError
  end

  describe "when name, version and desc are set" do
    before do
      subject.tap do |spec|
        spec.name = 'my-plugin'
        spec.version = "0.0.1"
        spec.description = "test plugin"
      end
    end
    it "is valid" do
      subject.validate!.should be_true
    end
  end
end
