require 'spec_helper'
describe Jenkins::Model::Describable do

  before do
    @plugin = double(Jenkins::Plugin)
    allow(Jenkins).to receive(:plugin).and_return(@plugin)
  end

  describe "when mixed into a class" do
    before do
      @class = Class.new(java.lang.Object)
      allow(@plugin).to receive(:register_describable)
      @class.send(:include, Jenkins::Model::Describable)
    end

    it "can't be described as plain old object" do
      expect {@class.describe_as Object}.to raise_error(Jenkins::Model::Describable::DescribableError)
    end

    it "can't be described as plain old java object" do
      expect {@class.describe_as java.lang.Object.new}.to raise_error(Jenkins::Model::Describable::DescribableError)
    end

    it "must be described as a java.lang.Class" do
      expect {@class.describe_as java.lang.Object}.not_to raise_error
    end
    
    describe "and no further specification is provided" do
      subject {@class}

      describe '#describe_as_type' do
        subject { super().describe_as_type }
        it {should be @class}
      end

      describe '#descriptor_is' do
        subject { super().descriptor_is }
        it {should be Jenkins::Model::DefaultDescriptor}
      end
    end

    describe "a subclass of that class" do
      before do
        @class.describe_as java.lang.Object
        def @class.to_s; "SuperClass" end
        @subclass = Class.new(@class)
        def @subclass.to_s; "SubClass" end
      end

      it "is registered as an extension" do
        expect(@plugin).to have_received(:register_describable).with(@subclass)
      end

      it "has the same java type as its superclass" do
        expect(@subclass.describe_as_type).to eql java.lang.Object
      end

      describe ". a sub-subclass" do
        before do
          @subsubclass = Class.new(@subclass)
        end

        it "is also registered as an extension of the original java type" do
          expect(@plugin).to have_received(:register_describable).with(@subsubclass)
        end

        it 'inherits its describe_as_type' do
          expect(@subsubclass.describe_as_type).to eql java.lang.Object
        end
      end
    end

    describe "with a custom descriptor type" do
      before do
        @class.describe_as java.lang.Object, :with => java.lang.String
        @subclass = Class.new(@class)
      end
      it "registers that custom descriptor" do
        expect(@plugin).to have_received(:register_describable).with(@subclass)
      end
      it "must be a real java class" do
        expect {@class.describe_as java.lang.Object, :with => Object}.to raise_error(Jenkins::Model::Describable::DescribableError)
      end
      it "inherits the descriptor type" do
        expect(@subclass.descriptor_is).to eql java.lang.String
      end
    end
  end
end
