require File.dirname(__FILE__) + '/test_helper.rb'

class TestConditionTypes < Test::Unit::TestCase
  fixtures :accounts, :users, :orders
  
  def setup
    setup_db
    load_fixtures
  end
  
  def teardown
    teardown_db
  end

  def test_sanitize
    condition = Searchgasm::Condition::BeginsWith.new(Account, Account.columns_hash["name"])
    condition.value = "Binary"
    assert_equal condition.sanitize, ["\"accounts\".\"name\" LIKE ?", "Binary%"]
    
    condition = Searchgasm::Condition::ChildOf.new(User)
    condition.value = User.first.id
    assert_equal condition.sanitize, ["\"users\".\"parent_id\" = ?", User.first.id]
    
    condition = Searchgasm::Condition::ChildOf.new(User)
    condition.value = User.first
    assert_equal condition.sanitize, ["\"users\".\"parent_id\" = ?", User.first.id]
    
    condition = Searchgasm::Condition::Contains.new(Account, Account.columns_hash["name"])
    condition.value = "Binary and blah"
    assert_equal condition.sanitize, ["\"accounts\".\"name\" LIKE ?", "%Binary and blah%"]
    
    condition = Searchgasm::Condition::DescendantOf.new(User)
    condition.value = User.find(1)
    assert_equal condition.sanitize, ["\"users\".\"id\" = ? OR \"users\".\"id\" = ?", 2, 3]
    
    condition = Searchgasm::Condition::DoesNotEqual.new(Account, Account.columns_hash["id"])
    condition.value = 12
    assert_equal condition.sanitize, "\"accounts\".\"id\" != 12"
    
    condition = Searchgasm::Condition::DoesNotEqual.new(Account, Account.columns_hash["id"])
    condition.value = [1,2,3,4]
    assert_equal condition.sanitize, "\"accounts\".\"id\" NOT IN (1,2,3,4)"
    
    condition = Searchgasm::Condition::DoesNotEqual.new(Account, Account.columns_hash["id"])
    condition.value = (1..10)
    assert_equal condition.sanitize, "\"accounts\".\"id\" NOT BETWEEN 1 AND 10"
    
    condition = Searchgasm::Condition::EndsWith.new(Account, Account.columns_hash["name"])
    condition.value = "Binary"
    assert_equal condition.sanitize, ["\"accounts\".\"name\" LIKE ?", "%Binary"]
    
    condition = Searchgasm::Condition::Equals.new(Account, Account.columns_hash["id"])
    condition.value = 12
    assert_equal condition.sanitize, "\"accounts\".\"id\" = 12"
    
    condition = Searchgasm::Condition::Equals.new(Account, Account.columns_hash["id"])
    condition.value = [1,2,3,4]
    assert_equal condition.sanitize, "\"accounts\".\"id\" IN (1,2,3,4)"
    
    condition = Searchgasm::Condition::Equals.new(Account, Account.columns_hash["id"])
    condition.value = (1..10)
    assert_equal condition.sanitize, "\"accounts\".\"id\" BETWEEN 1 AND 10"
    
    condition = Searchgasm::Condition::GreaterThan.new(Account, Account.columns_hash["id"])
    condition.value = 2
    assert_equal condition.sanitize, ["\"accounts\".\"id\" > ?", 2]
    
    condition = Searchgasm::Condition::GreaterThanOrEqualTo.new(Account, Account.columns_hash["id"])
    condition.value = 2
    assert_equal condition.sanitize, ["\"accounts\".\"id\" >= ?", 2]
    
    condition = Searchgasm::Condition::InclusiveDescendantOf.new(User)
    condition.value = User.find(1)
    assert_equal condition.sanitize, ["(\"users\".\"id\" = ?) OR (\"users\".\"id\" = ? OR \"users\".\"id\" = ?)", 1, 2, 3]
    
    condition = Searchgasm::Condition::Keywords.new(Account, Account.columns_hash["name"])
    condition.value = "freedom yeah, freedom YEAH right"
    assert_equal condition.sanitize, ["\"accounts\".\"name\" LIKE ? AND \"accounts\".\"name\" LIKE ? AND \"accounts\".\"name\" LIKE ?", "%freedom%", "%yeah%", "%right%"]
    
    condition = Searchgasm::Condition::Keywords.new(Account, Account.columns_hash["name"])
    condition.value = "%^$*(^$)"
    assert_equal condition.sanitize, nil
    
    condition = Searchgasm::Condition::LessThan.new(Account, Account.columns_hash["id"])
    condition.value = 2
    assert_equal condition.sanitize, ["\"accounts\".\"id\" < ?", 2]
    
    condition = Searchgasm::Condition::LessThanOrEqualTo.new(Account, Account.columns_hash["id"])
    condition.value = 2
    assert_equal condition.sanitize, ["\"accounts\".\"id\" <= ?", 2]
    
    condition = Searchgasm::Condition::SiblingOf.new(User)
    condition.value = User.find(2)
    assert_equal condition.sanitize, ["(\"users\".\"id\" != ?) AND (\"users\".\"parent_id\" = ?)", 2, 1]
  end
end
