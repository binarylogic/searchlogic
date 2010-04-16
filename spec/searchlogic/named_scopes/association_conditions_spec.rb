require File.expand_path(File.dirname(__FILE__) + "/../../spec_helper")

describe Searchlogic::NamedScopes::AssociationConditions do
  it "should create a named scope" do
    Company.users_username_like("bjohnson").proxy_options.should == User.username_like("bjohnson").proxy_options.merge(:joins => :users)
  end
  
  it "should create a deep named scope" do
    Company.users_orders_total_greater_than(10).proxy_options.should == Order.total_greater_than(10).proxy_options.merge(:joins => {:users => :orders})
  end
  
  it "should allow the use of foreign pre-existing named scopes" do
    User.named_scope :uname, lambda { |value| {:conditions => ["users.username = ?", value]} }
    Company.users_uname("bjohnson").proxy_options.should == User.uname("bjohnson").proxy_options.merge(:joins => :users)
  end
  
  it "should allow the use of deep foreign pre-existing named scopes" do
    pending
    Order.named_scope :big_id, :conditions => "orders.id > 100"
    Company.users_orders_big_id.proxy_options.should == Order.big_id.proxy_options.merge(:joins => {:users => :orders})
  end
  
  it "should allow the use of foreign pre-existing alias scopes" do
    User.alias_scope :username_has, lambda { |value| User.username_like(value) }
    Company.users_username_has("bjohnson").proxy_options.should == User.username_has("bjohnson").proxy_options.merge(:joins => :users)
  end
  
  it "should not raise errors for scopes that don't return anything" do
    User.alias_scope :blank_scope, lambda { |value| }
    Company.users_blank_scope("bjohnson").proxy_options.should == {:joins => :users}
  end
  
  it "should ignore polymorphic associations" do
    lambda { Fee.owner_created_at_gt(Time.now) }.should raise_error(NoMethodError)
  end
  
  it "should not allow named scopes on non existent association columns" do
    lambda { User.users_whatever_like("bjohnson") }.should raise_error(NoMethodError)
  end
  
  it "should not allow named scopes on non existent deep association columns" do
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
  
  it "should include optional associations" do
    pending # this is a problem with using inner joins and left outer joins
    Company.create
    company = Company.create
    user = company.users.create
    order = user.orders.create(:total => 20, :taxes => 3)
    Company.ascend_by_users_orders_total.all.should == Company.all
  end
  
  it "should implement exclusive scoping" do
    scope = Company.users_company_name_like("name").users_company_description_like("description")
    scope.scope(:find)[:joins].should == [
      "INNER JOIN \"users\" ON companies.id = users.company_id",
      "INNER JOIN \"companies\" companies_users ON \"companies_users\".id = \"users\".company_id"
    ]
    lambda { scope.all }.should_not raise_error
  end
  
  it "should not create the same join twice" do
    scope = Company.users_orders_total_gt(10).users_orders_taxes_lt(5).ascend_by_users_orders_total
    scope.scope(:find)[:joins].should == [
      "INNER JOIN \"users\" ON companies.id = users.company_id",
      "INNER JOIN \"orders\" ON orders.user_id = users.id"
    ]
    lambda { scope.count }.should_not raise_error
  end
  
  it "should not create the same join twice when traveling through the duplicate join" do
    scope = Company.users_username_like("bjohnson").users_orders_total_gt(100)
    scope.scope(:find)[:joins].should == [
      "INNER JOIN \"users\" ON companies.id = users.company_id",
      "INNER JOIN \"orders\" ON orders.user_id = users.id"
    ]
    lambda { scope.count }.should_not raise_error
  end
  
  it "should not create the same join twice when traveling through the deep duplicate join" do
    scope = Company.users_orders_total_gt(100).users_orders_line_items_price_gt(20)
    scope.scope(:find)[:joins].should == [
      "INNER JOIN \"users\" ON companies.id = users.company_id",
      "INNER JOIN \"orders\" ON orders.user_id = users.id",
      "INNER JOIN \"line_items\" ON line_items.order_id = orders.id"
    ]
    lambda { scope.all }.should_not raise_error
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
  
  it "should automatically add string joins if the association condition is using strings" do
    User.named_scope(:orders_big_id, :joins => User.inner_joins(:orders))
    Company.users_orders_big_id.proxy_options.should == {:joins=>[" INNER JOIN \"users\" ON users.company_id = companies.id ", " INNER JOIN \"orders\" ON orders.user_id = users.id "]}
  end

  it "should order the join statements ascending by the fieldnames so that we don't get double joins where the only difference is that the order of the fields is different" do
    company = Company.create
    user = company.users.create(:company_id => company.id)
    company.users.company_id_eq(company.id).should == [user]
  end
  
  it "should sanitize the scope on a foreign model instead of passing the raw options back to the original" do
    Company.named_scope(:users_count_10, :conditions => {:users_count => 10})
    User.company_users_count_10.proxy_options.should == {:conditions => "\"companies\".\"users_count\" = 10", :joins => :company}
  end
  
  it "should delegate to polymorphic relationships" do
    Audit.auditable_user_type_name_like("ben").proxy_options.should == {
      :conditions => ["users.name LIKE ?", "%ben%"],
      :joins => "INNER JOIN \"users\" ON \"users\".id = \"audits\".auditable_id AND \"audits\".auditable_type = 'User'"
    }
  end
  
  it "should delegate to polymorphic relationships (with a lazy split on _type_)" do
    Audit.auditable_user_type_some_type_id_like("ben").proxy_options.should == {
      :conditions => ["users.some_type_id LIKE ?", "%ben%"],
      :joins => "INNER JOIN \"users\" ON \"users\".id = \"audits\".auditable_id AND \"audits\".auditable_type = 'User'"
    }
  end
  
  it "should deep delegate to polymorphic relationships" do
    Audit.auditable_user_type_company_name_like("company").proxy_options.should == {
      :conditions => ["companies.name LIKE ?", "%company%"],
      :joins => ["INNER JOIN \"users\" ON \"users\".id = \"audits\".auditable_id AND \"audits\".auditable_type = 'User'", " INNER JOIN \"companies\" ON \"companies\".id = \"users\".company_id "]
    }
  end
  
  it "should allow any on a has_many relationship" do
    company1 = Company.create
    user1 = company1.users.create
    company2 = Company.create
    user2 = company2.users.create
    user3 = company2.users.create
    
    Company.users_id_equals_any([user2.id, user3.id]).all(:select => "DISTINCT companies.*").should == [company2]
  end
end