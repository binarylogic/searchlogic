require 'spec_helper'

describe Searchlogic::Conditions::AscendBy do 
  before(:each) do 
    @james = User.create(:name=>"James")
    @ben = User.create(:name=>"Ben")
  end

  it "orders users ascending on id" do 
    User.create(:name=>"Jon")
    users = User.ascend_by_id
    user_ids = users.map(&:id)
    user_ids.should eq([1,2,3])
  end


  it "orders ascending" do 
    Order.create(:total=>100)
    Order.create(:total=>125)
    Order.create(:total=>94)
    Order.create(:total=>112)
    orders = Order.ascend_by_total
    order_totals = orders.sort_by(&:total).map { |o| o.total }
    order_totals.should eq([94,100,112,125])
  end
end