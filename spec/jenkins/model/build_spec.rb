require 'spec_helper'

describe Jenkins::Model::Build do
  include Jenkins::Model

  before :each do
    @native = mock("AbstractBuild")
    @build = Jenkins::Model::Build.new(@native)
  end

  it "can be instantiated" do
    Jenkins::Model::Build.new
  end

  it "returns workspace path" do
    fs = Jenkins::FilePath.new(nil)
    fs.should_receive(:getRemote).and_return(".")
    @native.should_receive(:getWorkspace).and_return(fs)
    @build.workspace.to_s.should == "."
  end

  it "returns build variables as Hash-like" do
    @native.should_receive(:getBuildVariables).and_return("FOO" => "BAR")
    @build.build_var.should == {"FOO" => "BAR"}
  end

  it "returns environment variables as Hash-like" do
    @native.should_receive(:getEnvironment).with(nil).and_return("FOO" => "BAR")
    @build.env.should == {"FOO" => "BAR"}
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

end
