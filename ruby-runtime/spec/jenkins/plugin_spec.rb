require 'spec_helper'
require 'rspec-spies'
require 'tmpdir'

describe Jenkins::Plugin do

  describe 'registering an extension.' do
    before do
      @peer = mock(:name => 'org.jenkinsci.ruby.RubyPlugin')
      @peer.stub(:addExtension)
      @plugin = Jenkins::Plugin.new @peer
      @plugin.stub(:export) {|obj| obj}
    end
    describe 'When the extension class defines its order' do
      before do
        ext_class = Class.new
        def ext_class.order; 10;end
        @ext = ext_class.new
        @plugin.register_extension @ext
      end
      it 'uses it' do
        @peer.should have_received(:addExtension).with(@ext,10)
      end
    end
    describe 'When the extension is a proxy' do
      before do
        impl_class = Class.new
        def impl_class.order; 5; end
        @impl = impl_class.new
        @ext = Object.new
        @plugin.stub(:import) {@impl}
        @plugin.register_extension @ext
      end
      it 'uses the proxied objects class order' do
        @peer.should have_received(:addExtension).with(@ext, 5)
      end
    end

    describe 'when no order is defined' do
      before do
        @ext = Object.new
        @plugin.register_extension @ext
      end
      it 'uses 0' do
        @peer.should have_received(:addExtension).with(@ext, 0)
      end
    end
  end

  describe Jenkins::Plugin::Lifecycle do
    before do |variable|
      @plugin = Jenkins::Plugin.new mock(:name => 'org.jenkinsci.ruby.RubyPlugin')
      @plugin.on.start do |plugin|
        @start = plugin
      end
      @plugin.on.stop do |plugin|
        @stop = plugin
      end
      @plugin.start
      @plugin.stop
    end
    it "gets a callback on start" do
      @start.should be @plugin
    end
    it "gets a callback on stop" do
      @stop.should be @plugin
    end
  end
end
