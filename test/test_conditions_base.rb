require File.dirname(__FILE__) + '/test_helper.rb'

class TestConditionsBase < Test::Unit::TestCase
  def test_register_conditions
    Searchgasm::Conditions::Base.register_condition(Searchgasm::Condition::Keywords)
    assert [Searchgasm::Condition::Keywords], Searchgasm::Conditions::Base.conditions
    
    Searchgasm::Conditions::Base.register_condition(Searchgasm::Condition::Like)
    assert [Searchgasm::Condition::Keywords, Searchgasm::Condition::Like], Searchgasm::Conditions::Base.conditions
  end
  
  def test_association_names
    assert_equal ["account", "parent", "orders", "user_groups", "children"], Searchgasm::Cache::UserConditions.association_names
    assert_equal ["admin", "orders", "users"], Searchgasm::Cache::AccountConditions.association_names
  end
  
  def test_condition_names
    # This is tested thoroughly through the tests
  end
  
  def test_needed
    assert !Searchgasm::Conditions::Base.needed?(User, {})
    assert !Searchgasm::Conditions::Base.needed?(User, {:first_name => "Ben"})
    assert Searchgasm::Conditions::Base.needed?(User, {:first_name_contains => "Awesome"})
    assert !Searchgasm::Conditions::Base.needed?(User, {"orders.id" => 2})
  end
  
  def test_initialize
    conditions = Searchgasm::Cache::AccountConditions.new(:name_contains => "Binary")
    assert_equal conditions.klass, Account
    assert_equal conditions.name_contains, "Binary"
  end
  
  def test_any
    conditions = Searchgasm::Cache::AccountConditions.new
    assert !conditions.any?

    conditions = Searchgasm::Cache::AccountConditions.new(:any => true)
    assert conditions.any?
    conditions.any = "false"
    assert !conditions.any?
    
    conditions = Searchgasm::Cache::AccountConditions.new
    conditions.name_contains = "Binary"
    assert_equal ["\"accounts\".\"name\" LIKE ?", "%Binary%"], conditions.sanitize
    conditions.id = 1
    assert_equal ["(\"accounts\".\"id\" = 1) AND (\"accounts\".\"name\" LIKE ?)", "%Binary%"], conditions.sanitize
    conditions.any = true
    assert_equal ["(\"accounts\".\"id\" = 1) OR (\"accounts\".\"name\" LIKE ?)", "%Binary%"], conditions.sanitize
    conditions.any = false
    assert_equal ["(\"accounts\".\"id\" = 1) AND (\"accounts\".\"name\" LIKE ?)", "%Binary%"], conditions.sanitize
  end
  
  def test_auto_joins
    conditions = Searchgasm::Cache::AccountConditions.new
    assert_equal conditions.auto_joins, nil
    
    conditions.name_like = "Binary"
    assert_equal conditions.auto_joins, nil
    
    conditions.users.first_name_like = "Ben"
    assert_equal conditions.auto_joins, :users
    
    conditions.users.orders.description_like = "apple"
    assert_equal conditions.auto_joins, {:users => :orders} 
  end
  
  def test_inspect
    conditions = Searchgasm::Cache::AccountConditions.new
    assert_nothing_raised { conditions.inspect }
  end
  
  def test_sanitize
    conditions = Searchgasm::Cache::AccountConditions.new
    conditions.name_contains = "Binary"
    conditions.id_gt = 5
    now = Time.now
    conditions.created_after = now
    assert_equal ["(\"accounts\".\"created_at\" > ?) AND (\"accounts\".\"id\" > ?) AND (\"accounts\".\"name\" LIKE ?)", now, 5, "%Binary%"], conditions.sanitize
    
    # test out associations
    conditions.users.first_name_like = "Ben"
    conditions.users.id_gt = 10
    conditions.users.orders.total_lt = 500
    assert_equal ["(\"accounts\".\"created_at\" > ?) AND (\"accounts\".\"id\" > ?) AND (\"accounts\".\"name\" LIKE ?) AND ((\"users\".\"first_name\" LIKE ?) AND (\"users\".\"id\" > ?) AND (\"orders\".\"total\" < ?))", now, 5, "%Binary%", "%Ben%", 10, 500], conditions.sanitize
    
    # test that raw sql is returned
    conditions.conditions = "awesome"
    assert_equal "awesome", conditions.sanitize
  end
  
  def test_conditions
    conditions = Searchgasm::Cache::AccountConditions.new
    now = Time.now
    v = {:name_like => "Binary", :created_at_greater_than => now}
    conditions.conditions = v
    assert_equal v, conditions.conditions
    
    sql = "id in (1,2,3,4)"
    conditions.conditions = sql
    assert_equal sql, conditions.conditions
    assert_equal({}, conditions.send(:objects))
    
    v2 = {:id_less_than => 5, :name_begins_with => "Beginning of string"}
    conditions.conditions = v2
    assert_equal v2, conditions.conditions
    
    v = {:name_like => "Binary", :created_at_greater_than => now}
    conditions.conditions = v
    assert_equal v2.merge(v), conditions.conditions
    
    sql2 = "id > 5 and name = 'Test'"
    conditions.conditions = sql2
    assert_equal sql2, conditions.conditions
    assert_equal({}, conditions.send(:objects))
    
    conditions.name_contains = "awesome"
    assert_equal({:name_like => "awesome"}, conditions.conditions)
    
    conditions.conditions = {:id_gt => "", :id => "", :name => ["", "", ""], :name_starts_with => "Ben"}
    assert_equal({:name_like => "awesome", :name_begins_with => "Ben"}, conditions.conditions)
  end
  
  # Other general usage tests, need to clean these up
  
  def test_setting_conditions
    [Account, User, Order].each do |klass|
      conditions = "Searchgasm::Cache::#{klass}Conditions".constantize.new
      conditions.class.condition_names.each do |condition_name|
        conditions.send("#{condition_name}=", 1)
        assert_equal 1, conditions.send(condition_name)
      end
    end
  end
  
  def test_accessible_protected_conditions
    Account.conditions_accessible << :name_contains
    conditions = Searchgasm::Cache::AccountConditions.new
    conditions.conditions = {:created_after => Time.now, :name_contains => "Binary"}
    assert({:name_contains => "Binary"}, conditions.conditions)
    Account.send(:write_inheritable_attribute, :conditions_accessible, nil)
    
    Account.conditions_protected << :name_contains
    conditions = Searchgasm::Cache::AccountConditions.new
    now = Time.now
    conditions.conditions = {:created_after => now, :name_contains => "Binary"}
    assert({:created_after => now}, conditions.conditions)
    Account.send(:write_inheritable_attribute, :conditions_protected, nil)
  end
  
  def test_assert_valid_values
    conditions = Searchgasm::Cache::UserConditions.new
    assert_raise(NoMethodError) { conditions.conditions = {:unknown => "blah"} }
    assert_nothing_raised { conditions.conditions = {:first_name => "blah"} }
    assert_nothing_raised { conditions.conditions = {:first_name_contains => "blah"} }
  end
  
  def test_setting_associations
    conditions = Searchgasm::Cache::AccountConditions.new(:users => {:first_name_like => "Ben"})
    assert_equal conditions.users.first_name_like, "Ben"
    
    conditions.users.last_name_begins_with = "Ben"
    assert_equal conditions.users.last_name_begins_with, "Ben"
  end
  
  def test_virtual_columns
    conditions = Searchgasm::Cache::AccountConditions.new
    conditions.hour_of_created_gt = 2
    assert_equal ["strftime('%H', \"accounts\".\"created_at\") > ?", 2], conditions.sanitize
    conditions.dow_of_created_at_most = 5
    assert_equal ["(strftime('%w', \"accounts\".\"created_at\") <= ?) AND (strftime('%H', \"accounts\".\"created_at\") > ?)", 5, 2], conditions.sanitize
    conditions.month_of_created_at_nil = true
    assert_equal ["(strftime('%w', \"accounts\".\"created_at\") <= ?) AND (strftime('%H', \"accounts\".\"created_at\") > ?) AND (strftime('%m', \"accounts\".\"created_at\") is NULL)", 5, 2], conditions.sanitize
    conditions.min_of_hour_of_month_of_created_at_nil = true
    assert_equal ["(strftime('%w', \"accounts\".\"created_at\") <= ?) AND (strftime('%H', \"accounts\".\"created_at\") > ?) AND (strftime('%m', strftime('%H', strftime('%M', \"accounts\".\"created_at\"))) is NULL) AND (strftime('%m', \"accounts\".\"created_at\") is NULL)", 5, 2], conditions.sanitize
  end
  
  def test_objects
    conditions = Searchgasm::Cache::AccountConditions.new
    assert_equal({}, conditions.send(:objects))
    
    conditions.name_contains = "Binary"
    assert_equal 1, conditions.send(:objects).size
    
    conditions.users.first_name_contains = "Ben"
    assert_equal 2, conditions.send(:objects).size
  end
  
  def test_reset
    conditions = Searchgasm::Cache::AccountConditions.new
    
    conditions.name_contains = "Binary"
    assert_equal 1, conditions.send(:objects).size
    
    conditions.reset_name_like!
    conditions.reset_name_contains! # should set up aliases for reset
    assert_equal({}, conditions.send(:objects))
    
    conditions.users.first_name_like = "Ben"
    assert_equal 1, conditions.send(:objects).size
    
    conditions.reset_users!
    assert_equal({}, conditions.send(:objects))
    
    conditions.name_begins_with ="Binary"
    conditions.users.orders.total_gt = 200
    assert_equal 2, conditions.send(:objects).size
    
    conditions.reset_name_begins_with!
    assert_equal 1, conditions.send(:objects).size
    
    conditions.reset_users!
    assert_equal({}, conditions.send(:objects))
  end
end
