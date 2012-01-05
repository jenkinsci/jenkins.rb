require 'spec_helper'
require 'rspec-spies'
describe Jenkins::Model::Describable do

  before do
    @plugin = mock(Jenkins::Plugin)
    Jenkins::Plugin.stub(:instance).and_return(@plugin)
  end

  describe "when mixed into a class" do
    before do
      @class = Class.new
      @class.send(:include, Jenkins::Model::Describable)
      @plugin.stub(:register_describable)
    end


    it "can't be described as plain old object" do
      lambda {@class.describe_as Object}.should raise_error(Jenkins::Model::Describable::DescribableError)
    end

    it "can't be described as plain old java object" do
      lambda {@class.describe_as java.lang.Object.new}.should raise_error(Jenkins::Model::Describable::DescribableError)
    end

    it "must be described as a java.lang.Class" do
      lambda {@class.describe_as java.lang.Object}.should_not raise_error
    end

    describe "a subclass of that class" do
      before do
        @class.describe_as java.lang.Object
        @subclass = Class.new(@class)
      end

      it "is registered as an extension of the java type" do
        @plugin.should have_received(:register_describable).with(@subclass, java.lang.Object.java_class, nil)
      end

      describe ". a sub-subclass" do
        before do
          @subsubclass = Class.new(@subclass)
        end

        it "is also registered as an extension of the original java type" do
          @plugin.should have_received(:register_describable).with(@subsubclass, java.lang.Object.java_class, nil)
        end
      end
    end

    describe "with a custom descriptor type" do
      it "registers that custom descriptor" do
        @class.describe_as java.lang.Object, :with => java.lang.String
        @subclass = Class.new(@class)
        @plugin.should have_received(:register_describable).with(@subclass, java.lang.Object.java_class, java.lang.String.java_class)
      end
      it "must be a real java class" do
        lambda {@class.describe_as java.lang.Object, :with => Object}.should raise_error(Jenkins::Model::Describable::DescribableError)
      end
    end
  end
end
