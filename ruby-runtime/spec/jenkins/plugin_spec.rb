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

  describe "when plugin loads models" do
    include SpecHelper

    it "only loads *.rb file" do
      mktmpdir do |dir|
        # - foo.rb
        # - bar/
        #   - bar1.rb
        #   - bar2.rb
        #   - baz/
        #     - baz1.rb
        #     - baz2.rb
        #   - qux.rb
        # - quux.rb
        create_file(File.join(dir, "foo.rb"), "$T << :foo")
        Dir.mkdir(File.join(dir, "bar"))
        create_file(File.join(dir, "bar", "bar1.rb"), "$T << :bar1")
        create_file(File.join(dir, "bar", "bar2.rb"), "$T << :bar2")
        Dir.mkdir(File.join(dir, "bar", "baz"))
        create_file(File.join(dir, "bar", "baz", "baz1.rb"), "$T << :baz1")
        create_file(File.join(dir, "bar", "baz", "baz2.rb"), "$T << :baz2")
        create_file(File.join(dir, "bar", "qux.rb"), "$T << :qux")
        create_file(File.join(dir, "quux.rb"), "$T << :quux")
        file = mock(:name => 'java.io.File')
        file.stub(:getPath).and_return(dir)
        peer = mock(:name => 'org.jenkinsci.ruby.RubyPlugin')
        peer.stub(:getModelsPath).and_return(file)
        plugin = Jenkins::Plugin.new(peer)

        $T = []
        plugin.load_models
        foo = $T.index(:foo)
        bar1 = $T.index(:bar1)
        bar2 = $T.index(:bar2)
        baz1 = $T.index(:baz1)
        baz2 = $T.index(:baz2)
        qux = $T.index(:qux)
        quux = $T.index(:quux)

        bar1.should > foo
        bar1.should > quux

        bar2.should > foo
        bar2.should > quux

        baz1.should > foo
        baz1.should > bar1
        baz1.should > bar2
        baz1.should > qux
        baz1.should > quux

        baz2.should > foo
        baz2.should > bar1
        baz2.should > bar2
        baz2.should > qux
        baz2.should > quux

        qux.should > foo
        qux.should > quux
        [foo, bar1, bar2, baz1, baz2, qux, quux].should_not include(-1)
      end
    end
  end
end
