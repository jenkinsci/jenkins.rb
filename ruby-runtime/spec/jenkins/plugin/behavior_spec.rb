require 'spec_helper'
require 'jenkins/plugin/behavior'

describe Jenkins::Plugin::Behavior do
  before do
    module OhBehave
      extend Jenkins::Plugin::Behavior
      @implementations = []
      def self.implementations
        @implementations
      end
      implemented do |impl|
        @implementations << impl
      end
      module Foo
        def foo; 'foo' end
      end
      module Bar
        def bar; 'bar' end
      end
      module Baz
        def baz; 'baz' end
      end
      module Qux
        def qux; 'qux' end
      end
      module InstanceMethods
        include Foo
        include Bar
      end
      module ClassMethods
        include Baz
        include Qux
      end
    end
  end
  describe "when a behavior is included into a class" do
    before do
      @class = Class.new
      def @class.to_s; 'Behaving' end
      @class.send(:include, OhBehave)
    end

    its "methods in ClassMethods are available to the implementing class" do
      @class.baz.should eql 'baz'
      @class.qux.should eql 'qux'
    end

    its "methods in the InstanceMethods module are available to instances" do
      @class.new.tap do |i|
        i.foo.should eql 'foo'
        i.bar.should eql 'bar'
      end
    end

    its "implementation block is invoked" do
      OhBehave.implementations.should be_member @class
    end

    describe "and then that class is subclassed" do
      before do
        @subclass = Class.new(@class)
        def @subclass.to_s; 'BehavingSubclass' end
      end

      its "methods in ClassMethods are available to the subclass" do
        @subclass.baz.should eql 'baz'
        @subclass.qux.should eql 'qux'
      end

      its 'methods in InstanceMethods are available to subclass instances' do
        @subclass.new.foo.should eql 'foo'
        @subclass.new.bar.should eql 'bar'
      end

      its 'implementation block is invoked with the subclass' do
        OhBehave.implementations.should be_member @subclass
      end

      describe ". If it is subclassed yet again" do
        before do
          @subsubclass = Class.new(@subclass)
          def @subsubclass.to_s; "BehavingSubSubClass" end
        end
        its 'implementatin block is invoked with the sub-sub-class' do
          OhBehave.implementations.should be_member @subsubclass
        end
      end
    end
  end
  describe 'when a behavior is included into another module' do
    before do
      @module = Module.new
      @module.send(:include, OhBehave)
      @class = Class.new(Object)
      @class.send(:include, @module)
    end
    it 'reaches classes the module includes' do
      @class.baz.should eql 'baz'
      @class.new.foo.should eql 'foo'
    end
    its 'implementation callback is invoked for classes including that module' do
      OhBehave.implementations.should be_member @class
    end
    its 'implementation callback is NOT invoked for any intervening modules' do
      OhBehave.implementations.should_not be_member @module
    end
  end
end