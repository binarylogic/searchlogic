require 'spec_helper'

describe Searchlogic::Conditions::NormalizeInput do 
  before(:each) do 
    @james = User.new
    @james.name = "James"
    @james.save
    @ben = User.new
    @ben.name = "Ben"
    @ben.save
  end

  it "normalizes input without double underscore in associations" do 

    User.should_receive(:orders__line_items__price_greater_than).with(4).times(2)
    user = User.orders_line_items_price_greater_than(4)

    # no_name = User.new
    # no_name.name = nil
    # no_name.save
    # no_name_id = no_name.id
    # find_users = User.name_null.map { |u| u.id }
    # find_users.should eq([no_name_id])
  end
end