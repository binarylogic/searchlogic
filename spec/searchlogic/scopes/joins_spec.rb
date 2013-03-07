require 'spec_helper'

describe Searchlogic::ActiveRecordExt::Scopes::Conditions::Joins do 
  describe "joins" do 
    before(:each) do 
      order1 = Order.create(:total=>25, :line_items => [LineItem.create(:price => 12), LineItem.create(:price => 13)])
      order2 = Order.create(:total=>18, :line_items => [LineItem.create(:price => 9), LineItem.create(:price => 9)])
      order3 = Order.create(:total=>16, :line_items => [LineItem.create(:price => 8), LineItem.create(:price => 8)])
      order4 = Order.create(:total=>15, :line_items => [LineItem.create(:price => 8), LineItem.create(:price => 7)])
      @ben = User.create(:name=>"Ben", :orders => [order2, Order.create(:total =>26)])
      @john = User.create(:name=>"John", :orders => [order3])
      @tren = User.create(:name=>"Tren", :orders => [order4])
      @noorder = User.create(:name=>"noorder", :orders => [Order.create(:total => 0)])
      @james = User.create(:name=>"James", :orders => [order1, Order.create(:total =>25)], :age => 26, :username => "jawaja")

      company1 = Company.create(:name => "Neco", :users => [@james, @john])
      company2 = Company.create(:name => "ConcLive1", :users => [@tren])
      company3 = Company.create(:name => "ConcLive2", :users => [@ben])
    end

    it "returns all users with order total greater than 20" do 
      users = User.orders__total_greater_than(20)    
      # users.size.should eq(2)
      users.map(&:name).should eq(["James", "Ben"])
    end

    it "allows multiple joins" do  
      companies = Company.orders__total_greater_than(17)
      # companies.count.should eq(2)
      company_names = companies.map { |c| c.name }
      company_names.should eq(["Neco", "ConcLive2"])
    end

    it "allows multiple joins with underscore in association name " do 
      companies = Company.users__orders__line_items__price_greater_than(8)
      company_names = companies.map(&:name)
      company_names.should eq(["Neco", "ConcLive2"])    
    end


    it "it gives preference to columns over conflicting association names" do
      co1 = Company.create
      User.create(:count => 14, :company => co1 )
      Company.users_count_gt(10).should_not include(co1)
    end
  end
  describe "joining by association" do 

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

  it "orders descending by associated column" do 
    ordered_users = User.descend_by_orders_total
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
end