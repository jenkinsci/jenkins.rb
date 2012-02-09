require 'spec_helper'
require 'rspec-spies'

describe Jenkins::Listeners::RunListenerProxy do
  before do
    @listener = mock(Jenkins::Listeners::RunListener)
    @proxy = Jenkins::Listeners::RunListenerProxy.new(mock(Jenkins::Plugin, :name => 'test-plugin'), @listener)
    @build = mock(Jenkins::Model::Build)
    @console = mock(Jenkins::Model::Listener)
  end

  describe "when started" do
    before do
      @listener.stub(:started)
      @proxy.onStarted(@build, @console)
    end
    it 'invokes the started callback' do
      @listener.should have_received(:started).with(@build, @console)
    end
  end

  describe 'when completed' do
    before do
      @listener.stub(:completed)
      @proxy.onCompleted(@build, @console)
    end
    it 'invokes the completed callback' do
      @listener.should have_received(:completed).with(@build, @console)
    end
  end

  describe 'when finalized' do
    before do
      @listener.stub(:finalized)
      @proxy.onFinalized(@build)
    end
    it 'invokes the finalized callback' do
      @listener.should have_received(:finalized).with(@build)
    end
  end

  describe 'when deleted' do
    before do
      @listener.stub(:deleted)
      @proxy.onDeleted(@build)
    end
    it 'invokes the deleted callback' do
      @listener.should have_received(:deleted).with(@build)
    end
  end
end
