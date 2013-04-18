require 'spec_helper'
require 'rspec-spies'

describe Jenkins::Listeners::ItemListenerProxy do
  include ProxyHelper
  before do
    @proxy = Jenkins::Listeners::ItemListenerProxy.new(@plugin, @listener)
    @item = mock
  end

  describe "when created" do
    before do
      @listener.stub(:created)
      @proxy.onCreated(@item)
    end
    it 'invokes the created callback' do
      @listener.should have_received(:created).with(@item)
    end
  end
end
