require 'spec_helper'

describe Jenkins::Model::Listener do

  before do
    @output = java.io.ByteArrayOutputStream.new
    @java = Java.hudson.util.StreamTaskListener.new(@output)
    @listener = Jenkins::Model::Listener.new(@java)
  end

  it "logs messages" do
    @listener.info('Hi')
    @output.toString.should eql "Hi\n"
  end

  it "logs errors" do
    @listener.error('Oh no!')
    @output.toString.should match /^ERROR: Oh no/
  end

  it "logs fatal errors" do
    @listener.fatal('boom!')
    @output.toString.should match /^FATAL: boom/
  end

  it "logs if only severe" do
    @listener.level = Logger::INFO
    @listener.debug "debug"
    @listener.info "info"
    @output.toString.should == "info\n"
  end
end

