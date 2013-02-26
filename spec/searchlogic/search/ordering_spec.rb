require 'spec_helper'

describe "Searchlogic::SearchExt::Ordering" do 
  before(:each) do 
    Order.create(:total=> 22, :title => "jvans1", :user_id => 3)
    Order.create(:total=> 20, :title => "jvans1", :user_id => 2)
    Order.create(:total=> 19, :title => "jvans1", :user_id => 5)
    Order.create(:total=> 26, :user_id => 3)
    Order.create(:total=> 21, :user_id => 6)
  end

  it "ascend's by" do
    search = Order.searchlogic(:descend_by => "total")
    orders = search.all
    orders.count.should eq(5)
    orders.map(&:total).should eq([26,22,21,20,19])
  end
  it "descend's by" do
    search = Order.searchlogic(:ascend_by => "total")
    orders = search.all
    orders.count.should eq(5)
    orders.map(&:total).should eq([26,22,21,20,19].reverse)
  end
  it "ordering containing other conditions" do 
    search = Order.searchlogic(:descend_by => "total", :title => "jvans1", :user_id_gt => 2)
    orders = search.all
    orders.count.should eq(2)
    orders.map(&:total).should eq([22, 19])
  end

  it "accepts symbols as arguements" do 
    search = Order.searchlogic(:descend_by => :id)
    orders = search.all
    orders.count.should eq(5)
    orders.map(&:id).should eq([5,4 ,3, 2, 1])
  end

  it "redifining order overwites previous" do 
    search = Order.searchlogic(:descend_by => "total")
    search.ascend_by = :total
    search.conditions.should eq({:ascend_by => :total})

  end
end
