require File.dirname(__FILE__) + "/spec_helper"

require "hudson/core_ext/hash"

describe Hash do
  subject do
    {
      :simple => "simple",
      :under_score => "under_score",
      :"hyp-hen" => "hyphen",
      "str_under_score" => "str_under_score",
      "str-hyp-hen" => "str-hyp-hen"
    }
  end
  
  it do
    subject.with_clean_keys.should == {
      :simple => "simple",
      :under_score => "under_score",
      :hyp_hen => "hyphen",
      :str_under_score => "str_under_score",
      :str_hyp_hen => "str-hyp-hen"
    }
  end
end