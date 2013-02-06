require 'spec_helper'

describe Searchlogic::Conditions::Joins do 
  before(:each) do 
    order1 = Order.create(:total=>25)
    order2 = Order.create(:total=>19)
    @james = User.create(:name=>"James")
    @james.orders << order1

    @ben = User.create(:name=>"Ben")
    @ben.orders << order2

  end

  it "returns all users with order total greater than 20" do 
    users = User.orders_total_greater_than(20)
    users.count.should eq(1)
    users.first.name.should eq("James")
  end


end