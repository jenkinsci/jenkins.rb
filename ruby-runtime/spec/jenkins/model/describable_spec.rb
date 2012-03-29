require 'spec_helper'
require 'rspec-spies'
describe Jenkins::Model::Describable do

  before do
    @plugin = mock(Jenkins::Plugin)
    Jenkins.stub(:plugin).and_return(@plugin)
  end

  describe "when mixed into a class" do
    before do
      @class = Class.new(java.lang.Object)
      @plugin.stub(:register_describable)
      @class.send(:include, Jenkins::Model::Describable)
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
    
    describe "and no further specification is provided" do
      subject {@class}
      its(:describe_as_type) {should be @class}
      its(:descriptor_is) {should be Jenkins::Model::DefaultDescriptor}
    end

    describe "a subclass of that class" do
      before do
        @class.describe_as java.lang.Object
        def @class.to_s; "SuperClass" end
        @subclass = Class.new(@class)
        def @subclass.to_s; "SubClass" end
      end

      it "is registered as an extension" do
        @plugin.should have_received(:register_describable).with(@subclass)
      end

      it "has the same java type as its superclass" do
        @subclass.describe_as_type.should eql java.lang.Object
      end

      describe ". a sub-subclass" do
        before do
          @subsubclass = Class.new(@subclass)
        end

        it "is also registered as an extension of the original java type" do
          @plugin.should have_received(:register_describable).with(@subsubclass)
        end

        it 'inherits its describe_as_type' do
          @subsubclass.describe_as_type.should eql java.lang.Object
        end
      end
    end

    describe "with a custom descriptor type" do
      before do
        @class.describe_as java.lang.Object, :with => java.lang.String
        @subclass = Class.new(@class)
      end
      it "registers that custom descriptor" do
        @plugin.should have_received(:register_describable).with(@subclass)
      end
      it "must be a real java class" do
        lambda {@class.describe_as java.lang.Object, :with => Object}.should raise_error(Jenkins::Model::Describable::DescribableError)
      end
      it "inherits the descriptor type" do
        @subclass.descriptor_is.should eql java.lang.String
      end
    end
  end
end
