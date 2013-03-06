require 'spec_helper'
describe Searchlogic::ActiveRecordExt::Scopes::Conditions::Condition do 
  context ".matchers" do 
    it "returns an array of all matchers for conditions" do 
      ActiveRecord::Base.all_matchers.should be_kind_of(Array)
    end
  end

  context "#association_in_method" do
    it "returns an array of the klass and next method in a method with an association" do 
      User.association_in_method(:orders_line_items_total).should eq(["orders", "line_items_total"])
    end

    it "returns nil when no association in the method" do 
      User.association_in_method(:username_greater_than_or_equal).should be_nil
    end
  end 

  context "#memoized_scope" do
    it "should be created and then cached" do 
      User.send(:memoized_scope).keys.should be_empty
      User.name_greater_than_or_equal_to("James")
      User.send(:memoized_scope).keys.should eq([:name_greater_than_or_equal_to])
    end

  end

  it "should not allow conditions on columns that don't exist" do 
    expect{User.non_existant_col_equal(4).all}.to raise_error
  end
end