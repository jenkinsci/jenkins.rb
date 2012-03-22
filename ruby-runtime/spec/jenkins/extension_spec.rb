require 'spec_helper'
require 'jenkins/extension'

describe Jenkins::Extension do
  include SpecHelper

  it "adds the ordinal method to class" do
    class Foo
      class Foo
        include Jenkins::Extension
        ordinal 3
      end

      class Bar < Foo
        ordinal 5
      end

      Foo.ordinal.should == 3
      Bar.ordinal.should == 5
    end
  end
end
