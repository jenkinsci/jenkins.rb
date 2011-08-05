require 'spec_helper'

describe Jenkins::Model::Listener do

  before do
    @output = java.io.ByteArrayOutputStream.new
    @java = Java.hudson.util.StreamTaskListener.new(@output)
    @listener = Jenkins::Model::Listener.new(@java)
  end

  it "logs messages" do
    @listener.log('Hi')
    @output.toString.should eql "Hi"
  end

  it "logs errors" do
    @listener.error('Oh no!')
    @output.toString.should match /^ERROR: Oh no!/
  end

  it "logs fatal errors" do
    @listener.fatal('boom!')
    @output.toString.should match /^FATAL: boom!/
  end

  it "logs hyperlinks" do
    @java.should_receive(:hyperlink).with("/foo/bar", "click here")
    @listener.hyperlink("/foo/bar", "click here")
  end
end

