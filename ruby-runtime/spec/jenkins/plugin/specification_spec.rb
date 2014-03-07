require 'spec_helper'

describe Jenkins::Plugin::Specification do
  Specification = Jenkins::Plugin::Specification
  it "is invalid by default" do
    expect {subject.validate!}.to raise_error Jenkins::Plugin::SpecificationError
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
      expect(subject.validate!).to be_true
    end
  end

  describe "a spec loaded from a file" do
    subject {Specification.load(Pathname(__FILE__).dirname.join('example.pluginspec').to_s)}

    describe '#name' do
      subject { super().name }
      it {should eql "the-name"}
    end

    describe '#version' do
      subject { super().version }
      it {should eql "1.0.0"}
    end

    describe '#description' do
      subject { super().description }
      it {should eql "one great plugin"}
    end

    describe '#dependencies' do
      subject { super().dependencies }
      it {should be_empty}
    end
  end

  describe "find!" do
    it "looks for a .pluginspec in the current directory and loads it" do
      expect(Specification.find!(Pathname(__FILE__).dirname.to_s).name).to eql "the-name"
    end
    it "raises an exception if one cannot be found" do
      expect {Specification.find!('..')}.to raise_error Jenkins::Plugin::SpecificationNotFound
    end
  end
end
