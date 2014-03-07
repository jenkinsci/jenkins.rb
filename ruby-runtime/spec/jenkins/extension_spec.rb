require 'spec_helper'

describe Jenkins::Extension do

  before do
    @class = Class.new
    @class.send(:include, Jenkins::Extension)
  end

  describe "when an order is not specified" do
    it "uses 0" do
      @class.order.should eql 0
    end
  end

  describe "when an order is specified" do
    before do
      @class.order 3
    end
    it 'uses that order' do
      @class.order.should eql 3
    end

    describe ". A subclass" do
      before do
        @subclass = Class.new @class
      end
      it 'does not inherit the parents order' do
        @subclass.order.should eql 0
      end
      describe 'specifying its own order' do
        before do
          @subclass.order 5
        end
        it 'uses that order' do
          @subclass.order.should eql 5
        end
      end
    end
  end
end
