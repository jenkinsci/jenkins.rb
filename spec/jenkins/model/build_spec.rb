require 'spec_helper'

describe Jenkins::Model::Build do

  before :each do
    @native = mock("AbstractBuild")
    @subject = Jenkins::Model::Build.new(@native)
  end

  it "can be instantiated" do
    Jenkins::Model::Build.new
  end

  it "returns workspace path" do
    fs = Jenkins::FilePath.new(nil)
    fs.should_receive(:getRemote).and_return(".")
    @native.should_receive(:getWorkspace).and_return(fs)
    @subject.workspace.to_s.should == "."
  end

  it "returns build variables as Hash-like" do
    @native.should_receive(:getBuildVariables).and_return("FOO" => "BAR")
    @subject.build_var.should == {"FOO" => "BAR"}
  end

  it "returns environment variables as Hash-like" do
    @native.should_receive(:getEnvironment).with(nil).and_return("FOO" => "BAR")
    @subject.env.should == {"FOO" => "BAR"}
  end
end
