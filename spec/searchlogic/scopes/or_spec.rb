require 'spec_helper'

describe Searchlogic::ActiveRecordExt::Scopes::Conditions::Oor do 
  before(:each) do 
    l1 = LineItem.new(:price => 1)
    l2 = LineItem.new(:price => 4)
    l3 = LineItem.new(:price => 4)
    l4 = LineItem.new(:price => 4)
    l5 = LineItem.new(:price => 1)
    o1 = Order.new(:line_items => [l1, l2])
    o2 = Order.new(:line_items => [l3])
    o3 = Order.new(:line_items => [l4])
    o4 = Order.new(:line_items => [l5], :total => 15)

    User.create(:name => "Vanneman", :orders => [o1] )
    User.create(:name => "Bill", :username => "Bill_Vanneman_JR", :orders => [o4])
    User.create(:name=>"James")
    User.create(:name=>"Ben", :username => "america", :email => "Ben@Vanneman", :orders => [o3])
    User.create(:name=> "Tren", :username => "ANTJamesan", :orders => [o2])
    User.create(:name => "John", :username => "amicus")
  end

  it "gathers users based on OR condition" do 
    users = User.username_like_or_name_like("ame")
    users.count.should eq(3)
    usernames = users.map(&:name)

    usernames.should eq(["James", "Ben", "Tren"])
  end

  it "returns and ActiveRecord::Relation" do 
    users = User.username_like_or_name_like("ame").should be_kind_of(ActiveRecord::Relation)
  end

  it "works with 'or' in first method" do 
    users = User.id_greater_than_or_equal_to_or_age_lt(4)
  end 

  it "works with chain of associations" do 
    users = User.id_greater_than_or_equal_to_or_orders_line_items_price_eq(4)
    users.count.should eq(4)
    users.map(&:name).should eq( ["Vanneman", "Ben", "Tren", "John"])

  end
  it 'works with a long chain of ors with associations' do 
    users = User.id_greater_than_or_equal_to_or_orders_total_greater_than_or_equal_to_or_orders__line_items__id_eq(10)
    users.count.should eq(1)
  end
  it "gathers users based on OR condition omiting first compairson" do 
    users = User.username_or_name_like("ame")
    users.count.should eq(3)
    usernames = users.map(&:name)
    usernames.should eq(["James", "Ben", "Tren"])
  end

  it "should not get confused by the 'or' in find_or_create_by_* methods" do
    User.create(:name => "Fred")
    User.find_or_create_by_name("Fred").should be_a_kind_of User
  end

  it "should not get confused by the 'or' in compound find_or_create_by_* methods" do
    User.create(:name => "Fred", :username => "fredb")
    User.find_or_create_by_name_and_username("Fred", "fredb").should be_a_kind_of User
  end
  

  it "gathers users based on OR with two different conditions" do 
    users = User.username_like_or_name_equals("James")
    users.count.should eq(2)
    names = users.map(&:name)
    names.should eq(["James", "Tren"])
  end

  it "gather users based on OR with three conditions" do 
    users = User.username_like_or_name_equals_or_email_ends_with("Vanneman")
    users.count.should eq(3)
    names = users.map(&:name)
    names.should eq( ["Vanneman", "Bill", "Ben"])
  end

  it "gathers three OR conditions omitting specific conditions until end" do 
    users = User.username_or_name_or_email_like("Vanneman")
    users.count.should eq(3)
    names = users.map(&:name)
    names.should eq( ["Vanneman", "Bill", "Ben"])
  end


  
end