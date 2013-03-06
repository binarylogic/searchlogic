require 'spec_helper'

describe Searchlogic::ActiveRecordExt::Scopes::Conditions::Joins do 
  before(:each) do 
    order1 = Order.create(:total=>25, :line_items => [LineItem.create(:price => 12), LineItem.create(:price => 13)])
    order2 = Order.create(:total=>18, :line_items => [LineItem.create(:price => 9), LineItem.create(:price => 9)])
    order3 = Order.create(:total=>16, :line_items => [LineItem.create(:price => 6), LineItem.create(:price => 7)])
    order4 = Order.create(:total=>15, :line_items => [LineItem.create(:price => 8), LineItem.create(:price => 5)])
    User.create(:name=>"James", :orders => [order1])
    User.create(:name=>"Ben", :orders => [order2])
    User.create(:name=>"John", :orders => [order3])
    User.create(:name=>"Tren", :orders => [order4])
    User.create(:name=>"noorder", :orders => [Order.create(:total => 0)])
  end

  it "orders ascending by associated column" do
    ordered_users = User.ascend_by_orders_total
    ordered_users.count.should eq(5)
    names = ordered_users.map(&:name)
    names.should eq(["noorder", "Tren", "John", "Ben", "James"])
  end

  it "orders descending by associated column with singular name" do 
    ordered_users = User.descend_by_order__total
    ordered_users.count.should eq(5)
    ordered_users_names = ordered_users.map(&:name)
    ordered_users_names.should eq(["noorder", "Tren", "John", "Ben", "James"].reverse)
  end

  it "orders ascending by associations in method" do 
    users = User.ascend_by_orders_line_items_price
    users.count.should eq(8)
    names = users.map(&:name)
    names.should eq(["Tren",  "John", "John","Tren", "Ben", "Ben", "James", "James"])
  end

  it "orders by associations at end of method" do
    users = User.orders__line_items_ascend_by_id
    users.count.should eq(8)
    names = users.map(&:name)
    names.should eq(["James", "James", "Ben", "Ben", "John", "John", "Tren", "Tren"])
  end
end

