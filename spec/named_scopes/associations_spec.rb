require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe "Associations" do
  it "should create a named scope" do
    Company.users_username_like("bjohnson").proxy_options.should == User.username_like("bjohnson").proxy_options.merge(:joins => :users)
  end
  
  it "should create a deep named scope" do
    Company.users_orders_total_greater_than(10).proxy_options.should == Order.total_greater_than(10).proxy_options.merge(:joins => {:users => :orders})
  end
  
  it "should not allowed named scopes on non existent association columns" do
    lambda { User.users_whatever_like("bjohnson") }.should raise_error(NoMethodError)
  end
  
  it "should not allowed named scopes on non existent deep association columns" do
    lambda { User.users_orders_whatever_like("bjohnson") }.should raise_error(NoMethodError)
  end
  
  it "should allow named scopes to be called multiple times and reflect the value passed" do
    Company.users_username_like("bjohnson").proxy_options.should == User.username_like("bjohnson").proxy_options.merge(:joins => :users)
    Company.users_username_like("thunt").proxy_options.should == User.username_like("thunt").proxy_options.merge(:joins => :users)
  end
  
  it "should allow deep named scopes to be called multiple times and reflect the value passed" do
    Company.users_orders_total_greater_than(10).proxy_options.should == Order.total_greater_than(10).proxy_options.merge(:joins => {:users => :orders})
    Company.users_orders_total_greater_than(20).proxy_options.should == Order.total_greater_than(20).proxy_options.merge(:joins => {:users => :orders})
  end
  
  it "should have an arity of 1 if the underlying scope has an arity of 1" do
    Company.users_orders_total_greater_than(10)
    Company.named_scope_arity("users_orders_total_greater_than").should == Order.named_scope_arity("total_greater_than")
  end
  
  it "should have an arity of nil if the underlying scope has an arity of nil" do
    Company.users_orders_total_null
    Company.named_scope_arity("users_orders_total_null").should == Order.named_scope_arity("total_null")
  end
  
  it "should have an arity of -1 if the underlying scope has an arity of -1" do
    Company.users_id_equals_any
    Company.named_scope_arity("users_id_equals_any").should == User.named_scope_arity("id_equals_any")
  end
  
  it "should allow aliases" do
    Company.users_username_contains("bjohnson").proxy_options.should == User.username_contains("bjohnson").proxy_options.merge(:joins => :users)
  end
  
  it "should allow deep aliases" do
    Company.users_orders_total_gt(10).proxy_options.should == Order.total_gt(10).proxy_options.merge(:joins => {:users => :orders})
  end
  
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
  
  it "should include optional associations" do
    pending # this is a problem with using inner joins and left outer joins
    Company.create
    company = Company.create
    user = company.users.create
    order = user.orders.create(:total => 20, :taxes => 3)
    Company.ascend_by_users_orders_total.all.should == Company.all
  end
  
  it "should not create the same join twice" do
    company = Company.create
    user = company.users.create
    order = user.orders.create(:total => 20, :taxes => 3)
    Company.users_orders_total_gt(10).users_orders_taxes_lt(5).ascend_by_users_orders_total.all.should == Company.all
  end
  
  it "should not create the same join twice when traveling through the duplicate join" do
    Company.users_username_like("bjohnson").users_orders_total_gt(100).all.should == Company.all
  end
  
  it "should not create the same join twice when traveling through the duplicate join 2" do
    Company.users_orders_total_gt(100).users_orders_line_items_price_gt(20).all.should == Company.all
  end
  
  it "should allow the use of :include when a join was created" do
    company = Company.create
    user = company.users.create
    order = user.orders.create(:total => 20, :taxes => 3)
    Company.users_orders_total_gt(10).users_orders_taxes_lt(5).ascend_by_users_orders_total.all(:include => :users).should == Company.all
  end
  
  it "should allow the use of deep :include when a join was created" do
    company = Company.create
    user = company.users.create
    order = user.orders.create(:total => 20, :taxes => 3)
    Company.users_orders_total_gt(10).users_orders_taxes_lt(5).ascend_by_users_orders_total.all(:include => {:users => :orders}).should == Company.all
  end
  
  it "should allow the use of :include when traveling through the duplicate join" do
    company = Company.create
    user = company.users.create(:username => "bjohnson")
    order = user.orders.create(:total => 20, :taxes => 3)
    Company.users_username_like("bjohnson").users_orders_taxes_lt(5).ascend_by_users_orders_total.all(:include => :users).should == Company.all
  end
  
  it "should allow the use of deep :include when traveling through the duplicate join" do
    company = Company.create
    user = company.users.create(:username => "bjohnson")
    order = user.orders.create(:total => 20, :taxes => 3)
    Company.users_orders_taxes_lt(50).ascend_by_users_orders_total.all(:include => {:users => :orders}).should == Company.all
  end
end