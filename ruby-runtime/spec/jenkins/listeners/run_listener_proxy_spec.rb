require 'spec_helper'

describe Jenkins::Listeners::RunListenerProxy do
  include ProxyHelper
  before do
    @proxy = Jenkins::Listeners::RunListenerProxy.new(@plugin, @listener)
    @console = double(Jenkins::Model::Listener)
  end

  describe "when started" do
    before do
      allow(@listener).to receive(:started)
      @proxy.onStarted(@build, @console)
    end
    it 'invokes the started callback' do
      expect(@listener).to have_received(:started).with(@build, @console)
    end
  end

  describe 'when completed' do
    before do
      allow(@listener).to receive(:completed)
      @proxy.onCompleted(@build, @console)
    end
    it 'invokes the completed callback' do
      expect(@listener).to have_received(:completed).with(@build, @console)
    end
  end

  describe 'when finalized' do
    before do
      allow(@listener).to receive(:finalized)
      @proxy.onFinalized(@build)
    end
    it 'invokes the finalized callback' do
      expect(@listener).to have_received(:finalized).with(@build)
    end
  end

  describe 'when deleted' do
    before do
      allow(@listener).to receive(:deleted)
      @proxy.onDeleted(@build)
    end
    it 'invokes the deleted callback' do
      expect(@listener).to have_received(:deleted).with(@build)
    end
  end
end
