require 'spec_helper'

describe Searchlogic::ActiveRecordExt::Scopes::Conditions::ScopeProcedure do 
  before(:each) do 
    order1 = Order.create(:total=>25, :line_items => [LineItem.create(:price => 12), LineItem.create(:price => 13)])
    order2 = Order.create(:total=>18, :line_items => [LineItem.create(:price => 5), LineItem.create(:price => 9)])
    order3 = Order.create(:total=>16, :line_items => [LineItem.create(:price => 6), LineItem.create(:price => 7)], :id =>13)
    User.create(:name=>"James", :orders => [order1])
    User.create(:name=>"Tren", :orders => [order2]) 
    ben = User.create(:name=>"Ben", :orders => [order3], :id => 12, :orders => [order3])
    Company.create(:users => [ben], :name => "Ben's co")
  end
  it "can add a scope procedure to a method call" do 
    LineItem.scope(:expensive, lambda {LineItem.price_gt (7)})
    users = User.orders_line_items_expensive
    users.map(&:name).should eq(["James", "Tren"])
  end

  it "doesn't get confused with scope proc that has an aliased condition" do
    User.scope :doesnt_have_id_gt, lambda {|id1, id2| User.id_gt(id1).name_not_blank.orders_id_gt(id2) }
    users = User.doesnt_have_id_gt(2,2)
    users.count.should eq(1)
    users.first.name.should eq("Ben")

  end

  it "can add scope proc onto association taht also matches alias" do
    User.scope :has_id_gt, lambda { User.id_gt(2).name_not_blank.orders_id_gt(2) }
    users = Company.users_has_id_gt
    users.count.should eq(1)
    users.first.name.should eq("Ben's co")
  end
end

