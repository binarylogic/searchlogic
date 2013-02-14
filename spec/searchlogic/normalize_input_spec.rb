require 'spec_helper'

describe Searchlogic::Conditions::NormalizeInput do 
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

  it "normalizes input without double underscore in associations" do 
    companies = Company.users_orders_line_items_price_greater_than(8)
    company_names = companies.map(&:name)
    company_names.should eq(["Neco", "ConcLive2"])
  end
end