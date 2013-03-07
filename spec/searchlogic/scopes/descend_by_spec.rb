require 'spec_helper'

describe Searchlogic::ActiveRecordExt::Scopes::Conditions::DescendBy do 
  before(:each) do 
    User.create(:name=>"James", :orders=>[Order.create(:total => 25), Order.create(:total=>17)])
    User.create(:name=>"Ben", :orders=>[Order.create(:total => 19)])
    User.create(:name=>"Tren", :orders=>[Order.create(:total => 15)])
    User.create(:name=>"John", :orders=>[Order.create(:total => 12)])
    User.create(:name=>"Jon", :orders => [Order.create(:total => 0 )])
  end

  it "orders users based on id" do 
    users = User.descend_by_id
    user_ids = users.map(&:id)
    user_ids.should eq([5,4,3,2,1])
  end
  
  it "sorts on desending order total " do
    user_orders = User.descend_by_orders_total 
    user_orders.count.should eq(6)
    user_order_names = user_orders.map(&:name)
    user_order_names.should eq(["James", "Ben", "James", "Tren", "John", "Jon"])
  end

  it "orders based with an association" do 
    users = User.orders__descend_by_total
    users.count.should eq(6)
    names = users.map(&:name)
    names.should eq(["James", "Ben", "James", "Tren", "John", "Jon"])
  end

end