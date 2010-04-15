require File.expand_path(File.dirname(__FILE__) + "/../../spec_helper")

describe Searchlogic::NamedScopes::Ordering do
  it "should allow ascending" do
    Company.ascend_by_users_username.proxy_options.should == User.ascend_by_username.proxy_options.merge(:joins => :users)
  end
  
  it "should allow descending" do
    Company.descend_by_users_username.proxy_options.should == User.descend_by_username.proxy_options.merge(:joins => :users)
  end
  
  it "should allow deep ascending" do
    Company.ascend_by_users_orders_total.proxy_options.should == Order.ascend_by_total.proxy_options.merge(:joins => {:users => :orders})
  end
  
  it "should allow deep descending" do
    Company.descend_by_users_orders_total.proxy_options.should == Order.descend_by_total.proxy_options.merge(:joins => {:users => :orders})
  end
  
  it "should ascend with a belongs to" do
    User.ascend_by_company_name.proxy_options.should == Company.ascend_by_name.proxy_options.merge(:joins => :company)
  end
  
  it "should work through #order" do
    Company.order('ascend_by_users_username').proxy_options.should == Company.ascend_by_users_username.proxy_options
  end
end