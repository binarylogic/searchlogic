require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe "Consistency" do
  it "should merge joins with consistent conditions" do
    user_group = UserGroup.create
    user_group.users.user_groups_name_like("name").user_groups_id_gt(10).scope(:find)[:joins].should == [
      "INNER JOIN \"user_groups_users\" ON \"user_groups_users\".user_id = \"users\".id",
      "INNER JOIN \"user_groups\" ON \"user_groups\".id = \"user_groups_users\".user_group_id"
    ]
  end
  
  it "should limit join iterations to each scope and merge the joins if duplicates exist" do
    pending
    #Company.named_scope :name_like, lambda { |a| {:conditions => ["companies.name = ?", a], :joins => {:users => :company}} }
    #Company.named_scope :name1_like, lambda { |a| {:conditions => ["companies.description = ?", a], :joins => {:users => :company}} }
    #Company.named_scope :name2_like, lambda { |a| User.company_id_equals(2).proxy_options }
    
    #Company.name_like("a").name1_like("b").name2_like("c").count
    
    Company.users_company_name_like("name").users_company_description_like("description").users_company_created_at_after(Time.now).scope(:find).should == {}
  end
  
  it "shuold not convert joins to strings when delegating via associations" do
    User.alias_scope :has_id_gt, lambda { User.id_gt(10).has_name.orders_id_gt(10) }
    User.alias_scope :has_name, lambda { User.orders_created_at_after(Time.now).name_equals("ben").username_equals("ben") }
    Company.users_has_id_gt.proxy_options[:joins].should == {:users=>[:orders]}
  end
end
