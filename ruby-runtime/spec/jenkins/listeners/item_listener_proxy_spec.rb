require 'spec_helper'

describe Jenkins::Listeners::ItemListenerProxy do
  include ProxyHelper
  before do
    @proxy = Jenkins::Listeners::ItemListenerProxy.new(@plugin, @listener)
    @item = mock
    @src_item = mock
  end

  describe "when created" do
    before do
      @listener.stub(:created)
      @proxy.onCreated(@item)
    end
    xit 'invokes the created callback' do
      @listener.should have_received(:created).with(@item)
    end
  end


  describe "when copied" do
    before do
      @listener.stub(:copied)
      @proxy.onCopied(@src_item, @item)
    end
    xit 'invokes the copied callback' do
      @listener.should have_received(:copied).with(@src_item, @item)
    end
  end

  describe "when loaded" do
    before do
      @listener.stub(:loaded)
      @proxy.onLoaded()
    end
    it 'invokes the loaded callback' do
      @listener.should have_received(:loaded)
    end
  end

  describe "when deleted" do
    before do
      @listener.stub(:deleted)
      @proxy.onDeleted(@item)
    end
    xit 'invokes the deleted callback' do
      @listener.should have_received(:deleted).with(@item)
    end
  end

  describe "when renamed" do
    before do
      @listener.stub(:renamed)
      @proxy.onRenamed(@item, "oldname", "newname")
    end
    xit 'invokes the renamed callback' do
      @listener.should have_received(:renamed).with(@item, "oldname", "newname")
    end
  end

  describe "when updated" do
    before do
      @listener.stub(:updated)
      @proxy.onUpdated(@item)
    end
    xit 'invokes the updated callback' do
      @listener.should have_received(:updated).with(@item)
    end
  end

  describe "when before_shutdown" do
    before do
      @listener.stub(:before_shutdown)
      @proxy.onBeforeShutdown()
    end
    it 'invokes the before_shutdown callback' do
      @listener.should have_received(:before_shutdown)
    end
  end
end
