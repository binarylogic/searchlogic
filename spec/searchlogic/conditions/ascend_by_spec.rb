require 'spec_helper'

describe Searchlogic::Conditions::AscendBy do 
  before(:each) do 
    james = User.create(:name=>"James")
    ben = User.create(:name=>"Ben")
    tren = User.create(:name => "Tren")
    Order.create(:total=>100, :user => tren)
    Order.create(:total=>125, :user => ben)
    Order.create(:total=>94, :user => james)
    Order.create(:total=>112, :user => ben)
  end

  it "orders users ascending on id" do 
    User.create(:name=>"Jon")
    users = User.ascend_by_id
    user_ids = users.map(&:id)
    user_ids.should eq([1,2,3,4])
  end


  it "orders ascending" do 
    orders = Order.ascend_by_total
    order_totals = orders.sort_by(&:total).map { |o| o.total }
    order_totals.should eq([94,100,112,125])
  end

  it "orders based with an association" do 
    users = User.orders__descend_by_total
    users.count.should eq(4)
    names = users.map(&:name)
    names.should eq(["Ben", "Ben", "Tren", "James"])
  end

end