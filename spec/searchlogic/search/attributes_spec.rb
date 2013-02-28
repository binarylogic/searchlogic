require 'spec_helper'

describe Searchlogic::SearchExt::Attributes do 
  context "#ordering_by" do
    it "should return nil if we aren't ordering" do
      search = Order.search
      search.ordering_by.should be_nil
    end

    it "should return the column name for ascending" do
      search = User.search(:order => "ascend_by_first_name")
      search.ordering_by.should eq("first_name")
    end

  end

end