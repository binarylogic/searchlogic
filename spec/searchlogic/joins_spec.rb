require 'spec_helper'

describe Searchlogic::Conditions::Joins do 
  before(:each) do 
    order1 = Order.create(:total=>25, :line_items => [LineItem.create(:price => 12), LineItem.create(:price => 13)])
    order2 = Order.create(:total=>18, :line_items => [LineItem.create(:price => 9), LineItem.create(:price => 9)])
    order3 = Order.create(:total=>16, :line_items => [LineItem.create(:price => 8), LineItem.create(:price => 8)])
    order4 = Order.create(:total=>15, :line_items => [LineItem.create(:price => 8), LineItem.create(:price => 7)])
    @james = User.create(:name=>"James", :orders => [order1])
    @ben = User.create(:name=>"Ben", :orders => [order2])
    @john = User.create(:name=>"John", :orders => [order3])
    @tren = User.create(:name=>"Tren", :orders => [order4])
    @noorder = User.create(:name=>"noorder", :orders => [Order.create(:total => 0)])
    company1 = Company.create(:name => "Neco", :users => [@james, @john])
    company2 = Company.create(:name => "ConcLive1", :users => [@tren])
    company3 = Company.create(:name => "ConcLive2", :users => [@ben])
  end

  xit "returns all users with order total greater than 20" do 
    users = User.orders__total_greater_than(20)
    users.count.should eq(1)
    users.first.name.should eq("James")
  end
  xit "allows multiple joins" do  
    companies = Company.orders__total_greater_than(17)
    companies.count.should eq(2)
    company_names = companies.map { |c| c.name }
    company_names.should eq(["Neco", "ConcLive2"])
  end

  it "allows multiple joins with underscore in association name " do 
    companies = Company.users__orders__line_items__price_greater_than(8)
    ##NOTE fuck does this return a count of 4 in a 2 element array?
    companies.count.should eq(2)
    company_names = companies.map(&:name)
    company_names.should eq(["Neco", "ConcLive2"])
  end
end