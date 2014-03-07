require 'spec_helper'

describe Jenkins::Model do
  Model = Jenkins::Model

  it "has a display name which is settable via the class, and accessable via the class and instance" do
    cls = new_model do
      display_name "One-Off Class"
    end
    cls.display_name.should eql "One-Off Class"
    cls.new.display_name.should eql "One-Off Class"
  end

  it "passes down display_name capabilities to subclasses" do
    parent = new_model
    child = Class.new(parent)
    child.class_eval do
      display_name "Child"
    end
    child.display_name.should eql "Child"
  end

  it "passes down display_name capabilities to submodules" do
    submodule = Module.new
    submodule.send(:include, Jenkins::Model)
    cls = Class.new
    cls.send(:include, submodule)
    cls.display_name "SubAwesome"
    cls.display_name.should eql "SubAwesome"
    cls.new.display_name.should eql "SubAwesome"
  end

  it "has a default display name of the class name" do
    cls = new_model do
      def self.name
        "AwesomeClass"
      end
    end
    cls.display_name.should eql "AwesomeClass"
  end

  it "keeps a list of which of its properties are transient" do
    cls = new_model do
      transient :foo, :bar
    end
    cls.should be_transient(:foo)
    cls.should be_transient(:bar)
    cls.should_not be_transient(:baz)
  end

  it "includes parent classes's transient properties, but doesn't affect the parent property list" do
    parent = new_model do
      transient :foo
    end
    child = Class.new(parent)
    child.class_eval do
      transient :bar
    end
    parent.should_not be_transient(:bar)
    child.should be_transient(:foo)
    child.should be_transient(:bar)
  end

  private

  def new_model(&block)
    cls = Class.new
    cls.send(:include, Jenkins::Model)
    cls.class_eval(&block) if block_given?
    return cls
  end
end
