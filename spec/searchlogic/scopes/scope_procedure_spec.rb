require 'spec_helper'

describe Searchlogic::ActiveRecordExt::Scopes::Conditions::ScopeProcedure do 
  before(:each) do 
    order1 = Order.create(:total=>25, :line_items => [LineItem.create(:price => 12), LineItem.create(:price => 13)])
    order2 = Order.create(:total=>18, :line_items => [LineItem.create(:price => 5), LineItem.create(:price => 9)])
    @order3 = Order.create(:total=>16, :line_items => [LineItem.create(:price => 6), LineItem.create(:price => 7)], :id =>13)
    User.create(:name=>"James", :orders => [order1])
    User.create(:name=>"Tren", :orders => [order2]) 
    @ben = User.create(:name=>"Ben", :orders => [@order3], :id => 12, :username => "bjohnson")
    User.create(:username => "bjohnson")
    @benco = Company.create(:users => [@ben], :name => "Ben's co")
  end
  
  it "can add a scope procedure to a method call" do 
    LineItem.scope(:expensive, lambda {LineItem.price_gt (7)})
    users = User.orders_line_items_expensive
    users.map(&:name).should eq(["James", "Tren"])
  end

  it "allows the use of scopes on methods " do
    User.scope :has_id_gt, lambda {|id1, id2| User.id_gt(id1).name_not_blank.orders_id_gt(id2) }
    users = User.has_id_gt(2,2)
    users.count.should eq(1)
    users.first.name.should eq("Ben")
  end

  it "should ignore polymorphic associations" do
    expect { Fee.owner_created_at_gt(Time.now) }.to raise_error(NameError)
  end

  it "should not raise errors for scopes that don't return anything" do
    class User; scope :blank_scope, lambda { |value| where("1=1") };end
    expect{Company.users_blank_scope("bjohnson")}.to_not raise_error
  end

  it "can add scope proc onto association that also matches alias" do
    User.scope :has_id_gt, lambda { User.id_gt(2).name_not_blank.orders_id_gt(2) }
    users = Company.users_has_id_gt
    users.count.should eq(1)
    users.first.name.should eq("Ben's co")
  end

  it "should allow the use of deep foreign pre-existing named scopes" do
    class Order
      scope :big_id, lambda{ where("orders.id > 2")}
    end
    Company.users_orders_big_id.should eq([Company.first])
  end  

  it "should allow the use of foreign pre-existing alias scopes" do
    class User; scope :username_has, lambda { |value| username_like(value) }; end
    Company.users_username_has("bjohnson").should eq([@benco])
  end

end

