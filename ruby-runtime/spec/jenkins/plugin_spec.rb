require 'spec_helper'
require 'tmpdir'

describe Jenkins::Plugin do

  describe 'registering an extension.' do
    before do
      @peer = double(:name => 'org.jenkinsci.ruby.RubyPlugin')
      allow(@peer).to receive(:addExtension)
      @plugin = Jenkins::Plugin.new @peer
      allow(@plugin).to receive(:export) {|obj| obj}
    end
    describe 'When the extension class defines its order' do
      before do
        ext_class = Class.new
        def ext_class.order; 10;end
        @ext = ext_class.new
        @plugin.register_extension @ext
      end
      it 'uses it' do
        expect(@peer).to have_received(:addExtension).with(@ext,10)
      end
    end
    describe 'When the extension is a proxy' do
      before do
        impl_class = Class.new
        def impl_class.order; 5; end
        @impl = impl_class.new
        @ext = Object.new
        allow(@plugin).to receive(:import) {@impl}
        @plugin.register_extension @ext
      end
      it 'uses the proxied objects class order' do
        expect(@peer).to have_received(:addExtension).with(@ext, 5)
      end
    end

    describe 'when no order is defined' do
      before do
        @ext = Object.new
        @plugin.register_extension @ext
      end
      it 'uses 0' do
        expect(@peer).to have_received(:addExtension).with(@ext, 0)
      end
    end
  end

  describe Jenkins::Plugin::Lifecycle do
    before do |variable|
      @plugin = Jenkins::Plugin.new double(:name => 'org.jenkinsci.ruby.RubyPlugin')
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
      expect(@start).to be @plugin
    end
    it "gets a callback on stop" do
      expect(@stop).to be @plugin
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
        file = double(:name => 'java.io.File')
        allow(file).to receive(:getPath).and_return(dir)
        peer = double(:name => 'org.jenkinsci.ruby.RubyPlugin')
        allow(peer).to receive(:getModelsPath).and_return(file)
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

        expect(bar1).to be > foo
        expect(bar1).to be > quux

        expect(bar2).to be > foo
        expect(bar2).to be > quux

        expect(baz1).to be > foo
        expect(baz1).to be > bar1
        expect(baz1).to be > bar2
        expect(baz1).to be > qux
        expect(baz1).to be > quux

        expect(baz2).to be > foo
        expect(baz2).to be > bar1
        expect(baz2).to be > bar2
        expect(baz2).to be > qux
        expect(baz2).to be > quux

        expect(qux).to be > foo
        expect(qux).to be > quux
        expect([foo, bar1, bar2, baz1, baz2, qux, quux]).not_to include(-1)
      end
    end
  end
end
