require File.dirname(__FILE__) + '/test_helper.rb'

class TestConditionBase < Test::Unit::TestCase
  def test_condition_name
    assert_equal "equals", Searchgasm::Condition::Equals.condition_name
    assert_equal "keywords", Searchgasm::Condition::Keywords.condition_name
    assert_equal "greater_than_or_equal_to", Searchgasm::Condition::GreaterThanOrEqualTo.condition_name
  end
  
  def test_name_for_column
    assert_equal "id_equals", Searchgasm::Condition::Equals.name_for_column(Account.columns_hash["id"])
    assert_equal nil, Searchgasm::Condition::Keywords.name_for_column(Account.columns_hash["id"])
  end
  
  def test_ignore_meaningless?
    assert !Searchgasm::Condition::Equals.ignore_meaningless?
    assert Searchgasm::Condition::Keywords.ignore_meaningless?
    assert !Searchgasm::Condition::DoesNotEqual.ignore_meaningless?
  end
  
  def test_type_cast_sql_type
    assert_equal nil, Searchgasm::Condition::Equals.type_cast_sql_type
    assert_equal nil, Searchgasm::Condition::Keywords.type_cast_sql_type
    assert_equal "boolean", Searchgasm::Condition::Nil.type_cast_sql_type
    assert_equal "boolean", Searchgasm::Condition::Blank.type_cast_sql_type
    assert_equal nil, Searchgasm::Condition::GreaterThan.type_cast_sql_type
  end
  
  def test_string_column
    assert !Searchgasm::Condition::Base.string_column?(Account.columns_hash["id"])
    assert Searchgasm::Condition::Base.string_column?(Account.columns_hash["name"])
    assert !Searchgasm::Condition::Base.string_column?(Account.columns_hash["active"])
    assert Searchgasm::Condition::Base.string_column?(User.columns_hash["bio"])
  end
  
  def test_comparable_column
    assert Searchgasm::Condition::Base.comparable_column?(Account.columns_hash["id"])
    assert !Searchgasm::Condition::Base.comparable_column?(Account.columns_hash["name"])
    assert !Searchgasm::Condition::Base.comparable_column?(Account.columns_hash["active"])
    assert !Searchgasm::Condition::Base.comparable_column?(User.columns_hash["bio"])
    assert Searchgasm::Condition::Base.comparable_column?(Order.columns_hash["total"])
  end
  
  def test_initialize
    condition = Searchgasm::Condition::Keywords.new(Account, Account.columns_hash["name"])
    assert_equal condition.klass, Account
    assert_equal condition.column, Account.columns_hash["name"]
    
    condition = Searchgasm::Condition::GreaterThan.new(Account, "id")
    assert_equal condition.column, Account.columns_hash["id"]
  end
  
  def test_explicitly_set_value
    condition = Searchgasm::Condition::Keywords.new(Account, Account.columns_hash["name"])
    assert !condition.explicitly_set_value?
    condition.value = "test"
    assert condition.explicitly_set_value?
  end
  
  def test_name
    condition = Searchgasm::Condition::Keywords.new(Account, Account.columns_hash["name"])
    assert_equal "name_keywords", condition.name
    
    condition = Searchgasm::Condition::DescendantOf.new(User)
    assert_equal "descendant_of", condition.name
    
    condition = Searchgasm::Condition::DescendantOf.new(Account)
    assert_equal nil, condition.name
  end
  
  def test_sanitize
    # This is tested thoroughly in test_condition_types
  end
  
  def test_value
    # This is tested thoroughly in test_condition_types
  end
end
