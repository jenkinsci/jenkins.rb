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

  describe "a spec loaded from a file" do
    subject {Jenkins::Plugin::Specification.load(Pathname(__FILE__).dirname.join('example.pluginspec'))}
    its(:name) {should eql "the-name"}
    its(:version) {should eql "1.0.0"}
    its(:description) {should eql "one great plugin"}
    its(:dependencies) {should be_empty}
  end
end
