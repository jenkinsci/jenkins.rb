require 'spec_helper'

describe Jenkins::Extension do
  include SpecHelper

  it "adds the ordinal method to class" do
    class Foo
      class Foo
        include Jenkins::Extension
        order 3
      end

      class Bar < Foo
        order 5
      end

      Foo.order.should == 3
      Bar.order.should == 5
    end
  end
end
