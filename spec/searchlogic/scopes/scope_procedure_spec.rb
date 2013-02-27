require 'spec_helper'

describe Searchlogic::ActiveRecordExt::Scopes::Conditions::ScopeProcedure do 
  before(:each) do 
    order1 = Order.create(:total=>25, :line_items => [LineItem.create(:price => 12), LineItem.create(:price => 13)])
    order2 = Order.create(:total=>18, :line_items => [LineItem.create(:price => 5), LineItem.create(:price => 9)])
    order3 = Order.create(:total=>16, :line_items => [LineItem.create(:price => 6), LineItem.create(:price => 7)])
    User.create(:name=>"James", :orders => [order1])
    User.create(:name=>"Tren", :orders => [order2])

    User.create(:name=>"Ben", :orders => [order3])
  end
  it "can add a scope procedure to a method call" do 
    LineItem.scope_procedure(:expensive, lambda {LineItem.price_gt (7)})
    users = User.orders_line_items_expensive
    users.map(&:name).should eq(["James", "Tren"])
  end

end

