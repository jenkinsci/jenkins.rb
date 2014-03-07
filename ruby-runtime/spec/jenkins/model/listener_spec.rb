require 'spec_helper'

describe Jenkins::Model::Listener do

  before do
    @output = java.io.ByteArrayOutputStream.new
    @java = Java.hudson.util.StreamTaskListener.new(@output)
    @listener = Jenkins::Model::Listener.new(@java)
  end

  it "logs messages" do
    @listener.info('Hi')
    expect(@output.toString).to eql "Hi\n"
  end

  it "logs errors" do
    @listener.error('Oh no!')
    expect(@output.toString).to match /^ERROR: Oh no/
  end

  it "logs fatal errors" do
    @listener.fatal('boom!')
    expect(@output.toString).to match /^FATAL: boom/
  end

  it "logs if only severe" do
    @listener.level = Logger::INFO
    @listener.debug "debug"
    @listener.info "info"
    expect(@output.toString).to eq("info\n")
  end
end

