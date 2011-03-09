require 'spec_helper'

describe Searchlogic::ActiveRecord::Consistency do
  it "should merge joins with consistent conditions" do
    user_group = UserGroup.create
    user_group.users.user_groups_name_like("name").user_groups_id_gt(10).scope(:find)[:joins].should == [
      "INNER JOIN \"user_groups_users\" ON \"user_groups_users\".user_id = \"users\".id",
      "INNER JOIN \"user_groups\" ON \"user_groups\".id = \"user_groups_users\".user_group_id"
    ]
  end
  
  it "should respect parenthesis when reordering conditions" do
    joins = [
      "INNER JOIN \"table\" ON (\"b\".user_id = \"a\".id)",
      "INNER JOIN \"table\" ON (\"b\".id = \"a\".user_group_id)"
    ]
    ActiveRecord::Base.send(:merge_joins, joins).should == [
      "INNER JOIN \"table\" ON \"a\".id = \"b\".user_id",
      "INNER JOIN \"table\" ON \"a\".user_group_id = \"b\".id"
    ]
  end
  
  it "shuold not convert joins to strings when delegating via associations" do
    User.alias_scope :has_id_gt, lambda { User.id_gt(10).has_name.orders_id_gt(10) }
    User.alias_scope :has_name, lambda { User.orders_created_at_after(Time.now).name_equals("ben").username_equals("ben") }
    Company.users_has_id_gt.proxy_options[:joins].should == {:users=>[:orders]}
  end
end
