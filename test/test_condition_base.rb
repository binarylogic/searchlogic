require File.dirname(__FILE__) + '/test_helper.rb'

class TestConditionBase < Test::Unit::TestCase
  def test_condition_type_name
    assert_equal "equals", Searchgasm::Condition::Equals.condition_type_name
    assert_equal "keywords", Searchgasm::Condition::Keywords.condition_type_name
    assert_equal "greater_than_or_equal_to", Searchgasm::Condition::GreaterThanOrEqualTo.condition_type_name
  end
  
  def test_ignore_meaningless_value?
    assert !Searchgasm::Condition::Equals.ignore_meaningless_value?
    assert Searchgasm::Condition::Keywords.ignore_meaningless_value?
    assert !Searchgasm::Condition::NotEqual.ignore_meaningless_value?
  end
  
  def test_value_type
    assert_equal nil, Searchgasm::Condition::Equals.value_type
    assert_equal nil, Searchgasm::Condition::Keywords.value_type
    assert_equal :boolean, Searchgasm::Condition::Nil.value_type
    assert_equal :boolean, Searchgasm::Condition::Blank.value_type
    assert_equal nil, Searchgasm::Condition::GreaterThan.value_type
  end
  
  def test_initialize
    condition = Searchgasm::Condition::Keywords.new(Account, Account.columns_hash["name"])
    assert_equal condition.klass, Account
    assert_equal Account.columns_hash["name"], condition.column
    
    condition = Searchgasm::Condition::GreaterThan.new(Account, "id")
    assert_equal Account.columns_hash["id"], condition.column
    
    condition = Searchgasm::Condition::GreaterThan.new(Account, "id", :string, "some sql")
    assert_equal Account.columns_hash["id"], condition.column
    condition.value = "awesome"
    assert_equal ["some sql > ?", "awesome"], condition.sanitize
  end
  
  def test_explicitly_set_value
    condition = Searchgasm::Condition::Keywords.new(Account, Account.columns_hash["name"])
    assert !condition.explicitly_set_value?
    condition.value = "test"
    assert condition.explicitly_set_value?
  end
  
  def test_sanitize
    # This is tested thoroughly in test_condition_types
  end
  
  def test_value
    # This is tested thoroughly in test_condition_types
  end
end
