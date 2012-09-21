require 'spec_helper'

describe Jenkins::Plugin::Specification do
  Specification = Jenkins::Plugin::Specification
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
    subject {Specification.load(Pathname(__FILE__).dirname.join('example.pluginspec').to_s)}
    its(:name) {should eql "the-name"}
    its(:version) {should eql "1.0.0"}
    its(:description) {should eql "one great plugin"}
    its(:dependencies) {should be_empty}
  end

  describe "find!" do
    it "looks for a .pluginspec in the current directory and loads it" do
      Specification.find!(Pathname(__FILE__).dirname.to_s).name.should eql "the-name"
    end
    it "raises an exception if one cannot be found" do
      expect {Specification.find!('..')}.should raise_error Jenkins::Plugin::SpecificationNotFound
    end
  end
end
