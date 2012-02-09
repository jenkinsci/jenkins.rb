require 'spec_helper'

describe Jenkins::Model::Build do
  include Jenkins::Model
  include SpecHelper

  before :each do
    @native = mock(Java.hudson.model.AbstractBuild)
    @native.stub(:buildEnvironments).and_return(java.util.ArrayList.new)
    @build = Jenkins::Model::Build.new(@native)
  end

  it "returns workspace path" do
    fs = Jenkins::FilePath.new(nil)
    fs.should_receive(:getRemote).and_return(".")
    @native.should_receive(:getWorkspace).and_return(fs)
    @build.workspace.to_s.should == "."
  end

  it "can halt" do
    expect {@build.halt "stopping"}.should raise_error(Jenkins::Model::Build::Halt, "stopping")
  end

  it "can abort" do
    expect {@build.abort "aborting"}.should raise_error(Java.hudson.AbortException, "aborting")
  end

  describe "hash-y interface" do
    before do
      @val = Object.new
      @build['val'] = @val
    end

    it "gets" do
      @build['val'].should be @val
    end

    it "sets" do
      @build['val'] = :foo
      @build['val'].should be :foo
    end

    it "has symbol/string indifferent access" do
      @build[:val].should be @val
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
      @vars.get('FOO').should eql 'bar'
    end

    it "capitalizes and stringifies keys and stringifies values" do
      @vars.get('BAR').should eql 'baz'
    end
  end

end
