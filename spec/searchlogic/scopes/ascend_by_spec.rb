require 'spec_helper'

describe Searchlogic::ActiveRecordExt::Scopes::Conditions::AscendBy do 
  before(:each) do 
    @o1 = Order.create(:total=>100)
    @o2 = Order.create(:total=>125)
    @o3 = Order.create(:total=>94)
    @o4 = Order.create(:total=>112)
    @james = User.create(:name=>"James", :orders => [@o4])
    @ben = User.create(:name=>"Ben", :orders => [@o2, @o1])
    @tren = User.create(:name => "Tren", :orders => [@o3])

  end

  it "orders users ascending on id" do 
    User.create(:name=>"Jon")
    users = User.ascend_by_id
    user_ids = users.map(&:id)
    user_ids.should eq([1,2,3,4])
  end


  it "orders ascending" do 
    orders = Order.ascend_by_total
    order_totals = orders.sort_by(&:total).map { |o| o.total }
    order_totals.should eq([94,100,112,125])
  end

  it "orders with deep association and asending at begining of method" do 
    co1 = Company.create(:users =>[User.create(:orders =>[Order.create(:total =>75)])])
    co2 = Company.create(:users =>[User.create(:orders =>[Order.create(:total =>55)])])
    co3 = Company.create(:users =>[User.create(:orders =>[Order.create(:total =>45)])])
    Company.ascend_by_users_orders_total.should eq([co3, co2, co1])
  end

  it "orders based with an association" do 
    users = User.orders__ascend_by_total
    users.count.should eq(4)
    binding.pry
    users.should eq([@tren, @ben, @james, @ben])
  end

  it "should have priorty to columns over conflicting association columns" do
    co1 = Company.create(:users_count => 35, :users => [])
    co2 = Company.create(:users_count => 31, :users => [@tren, @ben, @james])
    Company.ascend_by_users_count.should eq([co2, co1])
  end

  it "should have order by custom scope" do
    User.column_names.should_not include("custom")
    class User;scope(:ascend_by_custom, lambda{ ascend_by_username.descend_by_id});end
    User.ascend_by_custom.should eq([@tren, @ben, @james])
  end
end