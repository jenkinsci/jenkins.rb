require 'spec_helper'

describe Jenkins::Listeners::ItemListenerProxy do
  include ProxyHelper
  before do
    @proxy = Jenkins::Listeners::ItemListenerProxy.new(@plugin, @listener)
    @item = double
    @src_item = double
  end

  describe "when created" do
    before do
      allow(@listener).to receive(:created)
      @proxy.onCreated(@item)
    end
    xit 'invokes the created callback' do
      expect(@listener).to have_received(:created).with(@item)
    end
  end


  describe "when copied" do
    before do
      allow(@listener).to receive(:copied)
      @proxy.onCopied(@src_item, @item)
    end
    xit 'invokes the copied callback' do
      expect(@listener).to have_received(:copied).with(@src_item, @item)
    end
  end

  describe "when loaded" do
    before do
      allow(@listener).to receive(:loaded)
      @proxy.onLoaded()
    end
    it 'invokes the loaded callback' do
      expect(@listener).to have_received(:loaded)
    end
  end

  describe "when deleted" do
    before do
      allow(@listener).to receive(:deleted)
      @proxy.onDeleted(@item)
    end
    xit 'invokes the deleted callback' do
      expect(@listener).to have_received(:deleted).with(@item)
    end
  end

  describe "when renamed" do
    before do
      allow(@listener).to receive(:renamed)
      @proxy.onRenamed(@item, "oldname", "newname")
    end
    xit 'invokes the renamed callback' do
      expect(@listener).to have_received(:renamed).with(@item, "oldname", "newname")
    end
  end

  describe "when updated" do
    before do
      allow(@listener).to receive(:updated)
      @proxy.onUpdated(@item)
    end
    xit 'invokes the updated callback' do
      expect(@listener).to have_received(:updated).with(@item)
    end
  end

  describe "when before_shutdown" do
    before do
      allow(@listener).to receive(:before_shutdown)
      @proxy.onBeforeShutdown()
    end
    it 'invokes the before_shutdown callback' do
      expect(@listener).to have_received(:before_shutdown)
    end
  end
end
