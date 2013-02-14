require 'spec_helper'

describe Searchlogic::Conditions::DescendBy do 
  before(:each) do 
    @james = User.create(:name=>"James", :orders=>[Order.create(:total => 25), Order.create(:total=>17)])
    @ben = User.create(:name=>"Ben", :orders=>[Order.create(:total => 19)])
    @Tren = User.create(:name=>"Tren", :orders=>[Order.create(:total => 15)])
    @John = User.create(:name=>"John", :orders=>[Order.create(:total => 12)])
    User.create(:name=>"Jon", :orders => [Order.create(:total => 0 )])
  end

  it "orders users based on id" do 
    users = User.descend_by_id
    user_ids = users.map(&:id)
    user_ids.should eq([5,4,3,2,1])
  end
  it "sorts on desending order total " do
    user_orders = User.descend_by_order_total 
    user_orders.count.should eq(6)
    user_order_names = user_orders.map(&:name)
    user_order_names.should eq(["James", "Ben", "James", "Tren", "John", "Jon"])
  end
end