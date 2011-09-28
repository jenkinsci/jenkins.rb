require 'spec_helper'
require 'tmpdir'

describe Jenkins::Plugin do
  it "is unbelievable that I don't have a spec for this class" do
    Jenkins::Plugin.instance_method(:initialize).should_not be_nil
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
