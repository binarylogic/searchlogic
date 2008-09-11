require File.dirname(__FILE__) + '/test_helper.rb'

class TestConditionBase < Test::Unit::TestCase
  fixtures :accounts, :users, :orders
  
  def setup
    setup_db
    load_fixtures
  end
  
  def teardown
    teardown_db
  end
  
  def test_condition_name
    assert_equal "equals", Searchgasm::Condition::Equals.condition_name
    assert_equal "keywords", Searchgasm::Condition::Keywords.condition_name
    assert_equal "greater_than_or_equal_to", Searchgasm::Condition::GreaterThanOrEqualTo.condition_name
  end
  
  def test_string_column
    
  end
  
  def test_comparable_column
    
  end
  
  def test_initialize
    condition = Searchgasm::Condition::Keywords.new(Account, Account.columns_hash["name"])
    assert_equal condition.klass, Account
    assert_equal condition.column, Account.columns_hash["name"]
    
    condition = Searchgasm::Condition::GreaterThan.new(Account, "id")
    assert_equal condition.column, Account.columns_hash["id"]
  end
  
  def test_explicitly_set_value
    condition = Searchgasm::Condition::Equals.new(Account, Account.columns_hash["name"])
    assert !condition.explicitly_set_value?
    condition.value = nil
    assert condition.explicitly_set_value?
    
    condition = Searchgasm::Condition::Keywords.new(Account, Account.columns_hash["name"])
    assert !condition.explicitly_set_value?
    condition.value = nil
    assert !condition.explicitly_set_value?
  end
  
  def test_ignore_blanks?
    condition = Searchgasm::Condition::Equals.new(Account, Account.columns_hash["id"])
    assert !condition.ignore_blanks?
    
    condition = Searchgasm::Condition::Keywords.new(Account, Account.columns_hash["name"])
    assert condition.ignore_blanks?
  end
  
  def test_value
    
  end
  
  def test_method_creation_in_scope
    # test ot make sure methods are not created across the board for all models
  end
end
