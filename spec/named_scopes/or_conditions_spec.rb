require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe "Or conditions" do
  it "should match username or name" do
    User.username_or_name_like("ben").proxy_options.should == {:conditions => "(users.name LIKE '%ben%') OR (users.username LIKE '%ben%')"}
  end
  
  it "should use the specified condition" do
    User.username_begins_with_or_name_like("ben").proxy_options.should == {:conditions => "(users.name LIKE '%ben%') OR (users.username LIKE 'ben%')"}
  end
  
  it "should use the last specified condition" do
    User.username_or_name_like_or_id_or_age_lt(10).proxy_options.should == {:conditions => "(users.age < 10) OR (users.id < 10) OR (users.name LIKE '%10%') OR (users.username LIKE '%10%')"}
  end
  
  it "should raise an error on unknown conditions" do
    lambda { User.usernme_begins_with_or_name_like("ben") }.should raise_error(Searchlogic::NamedScopes::OrConditions::UnknownConditionError)
  end
  
  it "should work well with _or_equal_to" do
    User.id_less_than_or_equal_to_or_age_gt(10).proxy_options.should == {:conditions => "(users.age > 10) OR (users.id <= 10)"}
  end
  
  it "should work well with _or_equal_to_any" do
    User.id_less_than_or_equal_to_all_or_age_gt(10).proxy_options.should == {:conditions => "(users.age > 10) OR (users.id <= 10)"}
  end
  
  it "should work well with _or_equal_to_all" do
    User.id_less_than_or_equal_to_any_or_age_gt(10).proxy_options.should == {:conditions => "(users.age > 10) OR (users.id <= 10)"}
  end
  
  it "should play nice with other scopes" do
    User.username_begins_with("ben").id_gt(10).age_not_nil.username_or_name_ends_with("ben").scope(:find).should ==
      {:conditions => "((users.name LIKE '%ben') OR (users.username LIKE '%ben')) AND ((users.age IS NOT NULL) AND ((users.id > 10) AND (users.username LIKE 'ben%')))"}
  end
end