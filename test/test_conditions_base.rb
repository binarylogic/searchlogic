require File.dirname(__FILE__) + '/test_helper.rb'

class TestConditionsBase < Test::Unit::TestCase
  def test_register_conditions
    Searchgasm::Conditions::Base.register_condition(Searchgasm::Condition::Keywords)
    assert [Searchgasm::Condition::Keywords], Searchgasm::Conditions::Base.conditions
    
    Searchgasm::Conditions::Base.register_condition(Searchgasm::Condition::Contains)
    assert [Searchgasm::Condition::Keywords, Searchgasm::Condition::Contains], Searchgasm::Conditions::Base.conditions
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
    assert_equal ["(\"accounts\".\"name\" LIKE ?) AND (\"accounts\".\"id\" = 1)", "%Binary%"], conditions.sanitize
    conditions.any = true
    assert_equal ["(\"accounts\".\"name\" LIKE ?) OR (\"accounts\".\"id\" = 1)", "%Binary%"], conditions.sanitize
    conditions.any = false
    assert_equal ["(\"accounts\".\"name\" LIKE ?) AND (\"accounts\".\"id\" = 1)", "%Binary%"], conditions.sanitize
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
    assert_equal conditions.sanitize, ["(\"accounts\".\"name\" LIKE ?) AND (\"accounts\".\"id\" > ?) AND (\"accounts\".\"created_at\" > ?)", "%Binary%", 5, now]
    
    # test out associations
    conditions.users.first_name_like = "Ben"
    conditions.users.id_gt = 10
    conditions.users.orders.total_lt = 500
    assert_equal conditions.sanitize, ["(\"accounts\".\"name\" LIKE ?) AND (\"accounts\".\"id\" > ?) AND (\"accounts\".\"created_at\" > ?) AND ((\"users\".\"first_name\" LIKE ?) AND (\"users\".\"id\" > ?) AND (\"orders\".\"total\" < ?))", "%Binary%", 5, now, "%Ben%", 10, 500]
    
    # test that raw sql is returned
    conditions.conditions = "awesome"
    assert_equal "awesome", conditions.sanitize
  end
  
  def test_conditions
    conditions = Searchgasm::Cache::AccountConditions.new
    now = Time.now
    v = {:name_contains => "Binary", :created_at_greater_than => now}
    conditions.conditions = v
    assert_equal v, conditions.conditions
    
    sql = "id in (1,2,3,4)"
    conditions.conditions = sql
    assert_equal sql, conditions.conditions
    assert_equal [], conditions.send(:objects)
    
    v2 = {:id_less_than => 5, :name_begins_with => "Beginning of string"}
    conditions.conditions = v2
    assert_equal v2, conditions.conditions
    
    v = {:name_contains => "Binary", :created_at_greater_than => now}
    conditions.conditions = v
    assert_equal v2.merge(v), conditions.conditions
    
    sql2 = "id > 5 and name = 'Test'"
    conditions.conditions = sql2
    assert_equal sql2, conditions.conditions
    assert_equal [], conditions.send(:objects)
    
    conditions.name_contains = "awesome"
    assert_equal({:name_contains => "awesome"}, conditions.conditions)
    
    conditions.conditions = {:id_gt => "", :name_starts_with => "Ben"}
    assert_equal({:name_contains => "awesome", :name_begins_with => "Ben"}, conditions.conditions)
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
    assert_raise(ArgumentError) { conditions.conditions = {:unknown => "blah"} }
    assert_nothing_raised { conditions.conditions = {:first_name => "blah"} }
    assert_nothing_raised { conditions.conditions = {:first_name_contains => "blah"} }
  end
  
  def test_setting_associations
    conditions = Searchgasm::Cache::AccountConditions.new(:users => {:first_name_like => "Ben"})
    assert_equal conditions.users.first_name_like, "Ben"
    
    conditions.users.last_name_begins_with = "Ben"
    assert_equal conditions.users.last_name_begins_with, "Ben"
  end
  
  def test_objects
    conditions = Searchgasm::Cache::AccountConditions.new
    assert_equal conditions.send(:objects), []
    
    conditions.name_contains = "Binary"
    assert_equal conditions.send(:objects).size, 1
    
    conditions.users.first_name_contains = "Ben"
    assert_equal conditions.send(:objects).size, 2
  end
  
  def test_reset
    conditions = Searchgasm::Cache::AccountConditions.new
    
    conditions.name_contains = "Binary"
    assert_equal 1, conditions.send(:objects).size
    
    conditions.reset_name_contains!
    assert_equal [], conditions.send(:objects)
    
    conditions.users.first_name_like = "Ben"
    assert_equal 1, conditions.send(:objects).size
    
    conditions.reset_users!
    assert_equal [], conditions.send(:objects)
    
    conditions.name_begins_with ="Binary"
    conditions.users.orders.total_gt = 200
    assert_equal 2, conditions.send(:objects).size
    
    conditions.reset_name_begins_with!
    assert_equal 1, conditions.send(:objects).size
    
    conditions.reset_users!
    assert_equal [], conditions.send(:objects)
  end
end
