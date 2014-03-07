require 'spec_helper'

describe Jenkins::Model::Build do
  include Jenkins::Model
  include SpecHelper

  before :each do
    @native = double(Java.hudson.model.AbstractBuild)
    allow(@native).to receive(:buildEnvironments).and_return(java.util.ArrayList.new)
    @build = Jenkins::Model::Build.new(@native)
  end

  it "returns workspace path" do
    fs = Jenkins::FilePath.new(nil)
    expect(fs).to receive(:getRemote).and_return(".")
    expect(@native).to receive(:getWorkspace).and_return(fs)
    expect(@build.workspace.to_s).to eq(".")
  end

  it "can halt" do
    expect {@build.halt "stopping"}.to raise_error(Jenkins::Model::Build::Halt, "stopping")
  end

  it "can abort" do
    expect {@build.abort "aborting"}.to raise_error(Java.hudson.AbortException, "aborting")
  end

  describe "hash-y interface" do
    before do
      @val = Object.new
      @build['val'] = @val
    end

    it "gets" do
      expect(@build['val']).to be @val
    end

    it "sets" do
      @build['val'] = :foo
      expect(@build['val']).to be :foo
    end

    it "has symbol/string indifferent access" do
      expect(@build[:val]).to be @val
    end
  end

  describe "environment variables" do
    before do
      pending "we need to get some full stack testing for this to fully work"
      @build.env['FOO'] = 'bar'
      @build.env[:bar] = :baz
      @vars = @native.getEnvironment(nil)
    end

    it "sets environment variables into the native build environment" do
      expect(@vars.get('FOO')).to eql 'bar'
    end

    it "capitalizes and stringifies keys and stringifies values" do
      expect(@vars.get('BAR')).to eql 'baz'
    end
  end

end
