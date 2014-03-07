require 'spec_helper'

describe Jenkins::Model do
  Model = Jenkins::Model

  it "has a display name which is settable via the class, and accessable via the class and instance" do
    cls = new_model do
      display_name "One-Off Class"
    end
    expect(cls.display_name).to eql "One-Off Class"
    expect(cls.new.display_name).to eql "One-Off Class"
  end

  it "passes down display_name capabilities to subclasses" do
    parent = new_model
    child = Class.new(parent)
    child.class_eval do
      display_name "Child"
    end
    expect(child.display_name).to eql "Child"
  end

  it "passes down display_name capabilities to submodules" do
    submodule = Module.new
    submodule.send(:include, Jenkins::Model)
    cls = Class.new
    cls.send(:include, submodule)
    cls.display_name "SubAwesome"
    expect(cls.display_name).to eql "SubAwesome"
    expect(cls.new.display_name).to eql "SubAwesome"
  end

  it "has a default display name of the class name" do
    cls = new_model do
      def self.name
        "AwesomeClass"
      end
    end
    expect(cls.display_name).to eql "AwesomeClass"
  end

  it "keeps a list of which of its properties are transient" do
    cls = new_model do
      transient :foo, :bar
    end
    expect(cls).to be_transient(:foo)
    expect(cls).to be_transient(:bar)
    expect(cls).not_to be_transient(:baz)
  end

  it "includes parent classes's transient properties, but doesn't affect the parent property list" do
    parent = new_model do
      transient :foo
    end
    child = Class.new(parent)
    child.class_eval do
      transient :bar
    end
    expect(parent).not_to be_transient(:bar)
    expect(child).to be_transient(:foo)
    expect(child).to be_transient(:bar)
  end

  private

  def new_model(&block)
    cls = Class.new
    cls.send(:include, Jenkins::Model)
    cls.class_eval(&block) if block_given?
    return cls
  end
end
