require File.dirname(__FILE__) + '/test_helper.rb'

class TestSearchgasmConditions < Test::Unit::TestCase
  fixtures :accounts, :users, :orders
  
  def setup
    setup_db
    load_fixtures
  end
  
  def teardown
    teardown_db
  end
  
  def test_register_conditions
    BinaryLogic::Searchgasm::Search::Conditions.register_condition(BinaryLogic::Searchgasm::Search::ConditionTypes::KeywordsCondition)
    assert [BinaryLogic::Searchgasm::Search::ConditionTypes::KeywordsCondition], BinaryLogic::Searchgasm::Search::Conditions.conditions
    
    BinaryLogic::Searchgasm::Search::Conditions.register_condition(BinaryLogic::Searchgasm::Search::ConditionTypes::ContainsCondition)
    assert [BinaryLogic::Searchgasm::Search::ConditionTypes::KeywordsCondition, BinaryLogic::Searchgasm::Search::ConditionTypes::ContainsCondition], BinaryLogic::Searchgasm::Search::Conditions.conditions
    
  end
  
  def test_initialize
    conditions = BinaryLogic::Searchgasm::Search::Conditions.new(Account, :name_contains => "Binary")
    assert_equal conditions.klass, Account
    assert_equal conditions.name_contains, "Binary"
  end
  
  def test_conditions_added
    # test to make sure all of the proper methods were add, testing condition_names basically
  end
  
  def test_setting_conditions
    [Account, User, Order].each do |klass|
      conditions = klass.new_conditions
      conditions.condition_names.each do |condition_name|
        conditions.send("#{condition_name}=", 1)
        assert_equal 1, conditions.send(condition_name)
      end
    end
  end
  
  def test_assert_valid_values
    
  end
  
  def test_setting_associations
    conditions = BinaryLogic::Searchgasm::Search::Conditions.new(Account, :users => {:first_name_like => "Ben"})
    assert_equal conditions.users.first_name_like, "Ben"
    
    conditions.users.last_name_begins_with = "Ben"
    assert_equal conditions.users.last_name_begins_with, "Ben"
  end
  
  def test_includes
    conditions = BinaryLogic::Searchgasm::Search::Conditions.new(Account)
    assert_equal conditions.includes, nil
    
    conditions.name_like = "Binary"
    assert_equal conditions.includes, nil
    
    conditions.users.first_name_like = "Ben"
    assert_equal conditions.includes, :users
    
    conditions.users.orders.description_like = "apple"
    assert_equal conditions.includes, {:users => :orders} 
  end
  
  def test_objects
    conditions = BinaryLogic::Searchgasm::Search::Conditions.new(Account)
    assert_equal conditions.objects, []
    
    conditions.name_contains = "Binary"
    assert_equal conditions.objects.size, 1
    
    conditions.users.first_name_contains = "Ben"
    assert_equal conditions.objects.size, 2
  end
  
  def test_reset
    conditions = BinaryLogic::Searchgasm::Search::Conditions.new(Account)
    
    conditions.name_contains = "Binary"
    assert_equal conditions.objects.size, 1
    
    conditions.reset_name_contains!
    assert_equal conditions.objects, []
    
    conditions.users.first_name_like = "Ben"
    assert_equal conditions.objects.size, 1
    
    conditions.reset_users!
    assert_equal conditions.objects, []
    
    conditions.name_begins_with ="Binary"
    conditions.users.orders.total_gt = 200
    conditions.users.first_name_keywords = "Silly name"
    conditions.reset!
    assert_equal conditions.objects, []
  end
  
  def test_sanitize
    conditions = BinaryLogic::Searchgasm::Search::Conditions.new(Account)
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
  end
  
  def test_value
    conditions = BinaryLogic::Searchgasm::Search::Conditions.new(Account)
    now = Time.now
    conditions.value = {:name_like => "Binary", :created_at_after => now}
    assert_equal conditions.value, {:name_contains => "Binary", :created_at_greater_than => now}
    
    conditions.value = "id in (1,2,3,4)"
    assert_equal conditions.value, {}
    assert_equal conditions.scope, "id in (1,2,3,4)"
  end
  
  def test_protection
    assert_raise(ArgumentError) { Account.new_conditions("(DELETE FROM users)") }
    assert_nothing_raised { Account.build_conditions!("(DELETE FROM users)") }
    
    account = Account.first
    
    assert_raise(ArgumentError) { account.users.build_conditions("(DELETE FROM users)") }
    assert_nothing_raised { account.users.build_conditions!("(DELETE FROM users)") }
  end
end
