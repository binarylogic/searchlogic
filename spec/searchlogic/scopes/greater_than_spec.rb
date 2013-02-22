require 'spec_helper'

describe Searchlogic::ActiveRecordExt::Scopes::Conditions::GreaterThan do 
  before(:each) do 
    User.create(:name => "James", :age => 26)
    User.create(:name => "Ben", :age => 30)
    User.create(:name => "Tren", :age => 27)
    Order.create(:title => "James' Order", :created_at => DateTime.new(2013, 2, 19))
    Order.create(:title => "Ben's Order", :created_at => DateTime.new(2014, 3, 29))

  end

  it "finds all other users greater than" do 
    find_users = User.age_gt(26).map { |u| u.name }
    find_users.should eq(["Ben", "Tren"])
  end

  it "parses datetime strings with chronic" do
    bens_order = Order.created_at_after("yesterday")
    bens_order.count.should eq(1)
    bens_order.first.title.should eq("Ben's Order")
  end
end