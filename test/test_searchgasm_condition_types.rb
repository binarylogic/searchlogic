require File.dirname(__FILE__) + '/test_helper.rb'

class TestSearchgasmConditionTypes < Test::Unit::TestCase
  fixtures :accounts, :users, :orders
  
  def setup
    setup_db
    load_fixtures
  end
  
  def teardown
    teardown_db
  end
  
  def test_condition_name
    assert_equal "equals", Searchgasm::Search::ConditionTypes::EqualsCondition.condition_name
    assert_equal "keywords", Searchgasm::Search::ConditionTypes::KeywordsCondition.condition_name
    assert_equal "greater_than_or_equal_to", Searchgasm::Search::ConditionTypes::GreaterThanOrEqualToCondition.condition_name
  end
  
  def test_string_column
    
  end
  
  def test_comparable_column
    
  end
  
  def test_initialize
    condition = Searchgasm::Search::ConditionTypes::KeywordsCondition.new(Account, Account.columns_hash["name"])
    assert_equal condition.klass, Account
    assert_equal condition.column, Account.columns_hash["name"]
    
    condition = Searchgasm::Search::ConditionTypes::GreaterThanCondition.new(Account, "id")
    assert_equal condition.column, Account.columns_hash["id"]
  end
  
  def test_explicitly_set_value
    condition = Searchgasm::Search::ConditionTypes::EqualsCondition.new(Account, Account.columns_hash["name"])
    assert !condition.explicitly_set_value?
    condition.value = nil
    assert condition.explicitly_set_value?
    
    condition = Searchgasm::Search::ConditionTypes::KeywordsCondition.new(Account, Account.columns_hash["name"])
    assert !condition.explicitly_set_value?
    condition.value = nil
    assert !condition.explicitly_set_value?
  end
  
  def test_ignore_blanks?
    condition = Searchgasm::Search::ConditionTypes::EqualsCondition.new(Account, Account.columns_hash["id"])
    assert !condition.ignore_blanks?
    
    condition = Searchgasm::Search::ConditionTypes::KeywordsCondition.new(Account, Account.columns_hash["name"])
    assert condition.ignore_blanks?
  end

  def test_sanitize
    condition = Searchgasm::Search::ConditionTypes::BeginsWithCondition.new(Account, Account.columns_hash["name"])
    condition.value = "Binary"
    assert_equal condition.sanitize, ["\"accounts\".\"name\" LIKE ?", "Binary%"]
    
    condition = Searchgasm::Search::ConditionTypes::ChildOfCondition.new(User)
    condition.value = User.first.id
    assert_equal condition.sanitize, ["\"users\".\"parent_id\" = ?", User.first.id]
    
    condition = Searchgasm::Search::ConditionTypes::ChildOfCondition.new(User)
    condition.value = User.first
    assert_equal condition.sanitize, ["\"users\".\"parent_id\" = ?", User.first.id]
    
    condition = Searchgasm::Search::ConditionTypes::ContainsCondition.new(Account, Account.columns_hash["name"])
    condition.value = "Binary and blah"
    assert_equal condition.sanitize, ["\"accounts\".\"name\" LIKE ?", "%Binary and blah%"]
    
    condition = Searchgasm::Search::ConditionTypes::DescendantOfCondition.new(User)
    condition.value = User.find(1)
    assert_equal condition.sanitize, ["\"users\".\"id\" = ? OR \"users\".\"id\" = ?", 2, 3]
    
    condition = Searchgasm::Search::ConditionTypes::DoesNotEqualCondition.new(Account, Account.columns_hash["id"])
    condition.value = 12
    assert_equal condition.sanitize, "\"accounts\".\"id\" != 12"
    
    condition = Searchgasm::Search::ConditionTypes::DoesNotEqualCondition.new(Account, Account.columns_hash["id"])
    condition.value = [1,2,3,4]
    assert_equal condition.sanitize, "\"accounts\".\"id\" NOT IN (1,2,3,4)"
    
    condition = Searchgasm::Search::ConditionTypes::DoesNotEqualCondition.new(Account, Account.columns_hash["id"])
    condition.value = (1..10)
    assert_equal condition.sanitize, "\"accounts\".\"id\" NOT BETWEEN 1 AND 10"
    
    condition = Searchgasm::Search::ConditionTypes::EndsWithCondition.new(Account, Account.columns_hash["name"])
    condition.value = "Binary"
    assert_equal condition.sanitize, ["\"accounts\".\"name\" LIKE ?", "%Binary"]
    
    condition = Searchgasm::Search::ConditionTypes::EqualsCondition.new(Account, Account.columns_hash["id"])
    condition.value = 12
    assert_equal condition.sanitize, "\"accounts\".\"id\" = 12"
    
    condition = Searchgasm::Search::ConditionTypes::EqualsCondition.new(Account, Account.columns_hash["id"])
    condition.value = [1,2,3,4]
    assert_equal condition.sanitize, "\"accounts\".\"id\" IN (1,2,3,4)"
    
    condition = Searchgasm::Search::ConditionTypes::EqualsCondition.new(Account, Account.columns_hash["id"])
    condition.value = (1..10)
    assert_equal condition.sanitize, "\"accounts\".\"id\" BETWEEN 1 AND 10"
    
    condition = Searchgasm::Search::ConditionTypes::GreaterThanCondition.new(Account, Account.columns_hash["id"])
    condition.value = 2
    assert_equal condition.sanitize, ["\"accounts\".\"id\" > ?", 2]
    
    condition = Searchgasm::Search::ConditionTypes::GreaterThanOrEqualToCondition.new(Account, Account.columns_hash["id"])
    condition.value = 2
    assert_equal condition.sanitize, ["\"accounts\".\"id\" >= ?", 2]
    
    condition = Searchgasm::Search::ConditionTypes::InclusiveDescendantOfCondition.new(User)
    condition.value = User.find(1)
    assert_equal condition.sanitize, ["(\"users\".\"id\" = ?) OR (\"users\".\"id\" = ? OR \"users\".\"id\" = ?)", 1, 2, 3]
    
    condition = Searchgasm::Search::ConditionTypes::KeywordsCondition.new(Account, Account.columns_hash["name"])
    condition.value = "freedom yeah, freedom YEAH right"
    assert_equal condition.sanitize, ["\"accounts\".\"name\" LIKE ? AND \"accounts\".\"name\" LIKE ? AND \"accounts\".\"name\" LIKE ?", "%freedom%", "%yeah%", "%right%"]
    
    condition = Searchgasm::Search::ConditionTypes::KeywordsCondition.new(Account, Account.columns_hash["name"])
    condition.value = "%^$*(^$)"
    assert_equal condition.sanitize, nil
    
    condition = Searchgasm::Search::ConditionTypes::LessThanCondition.new(Account, Account.columns_hash["id"])
    condition.value = 2
    assert_equal condition.sanitize, ["\"accounts\".\"id\" < ?", 2]
    
    condition = Searchgasm::Search::ConditionTypes::LessThanOrEqualToCondition.new(Account, Account.columns_hash["id"])
    condition.value = 2
    assert_equal condition.sanitize, ["\"accounts\".\"id\" <= ?", 2]
    
    condition = Searchgasm::Search::ConditionTypes::SiblingOfCondition.new(User)
    condition.value = User.find(2)
    assert_equal condition.sanitize, ["(\"users\".\"id\" != ?) AND (\"users\".\"parent_id\" = ?)", 2, 1]
  end
  
  def test_value
    
  end
end
