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

  it "orders on the correct column whena  scope already with joins values is ordered" do 
    james = User.create(:name=>"James", :age =>20, :username => "jvans1" )
    zed = User.create(:name=>"Zed", :age =>20, :username => "jvans1" )
    tren = User.create(:name => "Tren", :username =>"jvans")
    User.create(:name=>"Ben", :username =>"jvans1")
    jv = User.create(:name=>"James Vanneman", :age =>21, :username => "jvans1")
    l1 = LineItem.create(:price =>2)
    james.orders = [Order.create(:line_items => [l1])]
    tren.orders = [Order.create(:line_items => [LineItem.create(:price =>5)])]
    jv.orders = [Order.create(:line_items => [LineItem.create(:price =>1)])]
    c1 = Company.create(:identifier => 1, :users => [james, zed])
    c2 = Company.create(:identifier => 2, :users => [tren])
    c3 = Company.create(:identifier => 4, :users => [jv])

    search = Company.search(:users_orders_line_items_price_lte => "2",  :order => :descend_by_id )
    search.all.should eq([c3, c1])
    search = LineItem.search(:order_user_name_equal => "James", :order => :descend_by_price)
    search.all.should eq([l1])
  end
end