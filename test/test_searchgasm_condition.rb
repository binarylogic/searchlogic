require File.dirname(__FILE__) + '/test_helper.rb'

class TestSearchgasmCondition < Test::Unit::TestCase
  fixtures :accounts, :users, :orders
  
  def setup
    setup_db
    load_fixtures
  end
  
  def teardown
    teardown_db
  end
  
  def test_generate_name
    name = BinaryLogic::Searchgasm::Search::Condition.generate_name(Account.columns_hash["id"], :equals)
    assert_equal name, "id_equals"
    
    name = BinaryLogic::Searchgasm::Search::Condition.generate_name("test", :equals)
    assert_equal name, "test_equals"
    
    name = BinaryLogic::Searchgasm::Search::Condition.generate_name("test", "")
    assert_equal name, "test"
    
    name = BinaryLogic::Searchgasm::Search::Condition.generate_name("test", nil)
    assert_equal name, "test"
  end
  
  def test_initialize
    condition = BinaryLogic::Searchgasm::Search::Condition.new(:equals, Account, Account.columns_hash["id"])
    assert_equal condition.condition, :equals
    assert_equal condition.name, "id_equals"
    assert_equal condition.klass, Account
    assert_equal condition.column, Account.columns_hash["id"]
    
    condition = BinaryLogic::Searchgasm::Search::Condition.new(:equals, Account, "id")
    assert_equal condition.column, Account.columns_hash["id"]
  end
  
  def test_explicitly_set_value
    condition = BinaryLogic::Searchgasm::Search::Condition.new(:equals, Account, Account.columns_hash["id"])
    assert !condition.explicitly_set_value?
    condition.value = nil
    assert condition.explicitly_set_value?
  end
  
  def test_ignore_blanks?
    condition = BinaryLogic::Searchgasm::Search::Condition.new(:equals, Account, Account.columns_hash["id"])
    assert !condition.ignore_blanks?
    
    condition = BinaryLogic::Searchgasm::Search::Condition.new(:greater_than, Account, Account.columns_hash["id"])
    assert condition.ignore_blanks?
    
    condition = BinaryLogic::Searchgasm::Search::Condition.new(:contains, Account, Account.columns_hash["name"])
    assert condition.ignore_blanks?
  end
  
  def test_sanitize
    condition = BinaryLogic::Searchgasm::Search::Condition.new(:equals, Account, Account.columns_hash["id"])
    condition.value = 12
    assert_equal condition.sanitize, ["\"accounts\".\"id\" = 12"]
    
    condition = BinaryLogic::Searchgasm::Search::Condition.new(:equals, Account, Account.columns_hash["id"])
    condition.value = nil
    assert_equal condition.sanitize, ["\"accounts\".\"id\" IS NULL"]
    
    condition = BinaryLogic::Searchgasm::Search::Condition.new(:equals, Account, Account.columns_hash["id"])
    condition.value = (1..100)
    assert_equal condition.sanitize, ["\"accounts\".\"id\" BETWEEN 1 AND 100"]
    
    condition = BinaryLogic::Searchgasm::Search::Condition.new(:equals, Account, Account.columns_hash["id"])
    condition.value = [1,2,3,4,5]
    assert_equal condition.sanitize, ["\"accounts\".\"id\" IN (1,2,3,4,5)"]
    
    condition = BinaryLogic::Searchgasm::Search::Condition.new(:does_not_equal, Account, Account.columns_hash["id"])
    condition.value = 12
    assert_equal condition.sanitize, ["\"accounts\".\"id\" != 12"]
    
    condition = BinaryLogic::Searchgasm::Search::Condition.new(:does_not_equal, Account, Account.columns_hash["id"])
    condition.value = nil
    assert_equal condition.sanitize, ["\"accounts\".\"id\" IS NOT NULL"]
    
    condition = BinaryLogic::Searchgasm::Search::Condition.new(:does_not_equal, Account, Account.columns_hash["id"])
    condition.value = (1..100)
    assert_equal condition.sanitize, ["\"accounts\".\"id\" NOT BETWEEN 1 AND 100"]
    
    condition = BinaryLogic::Searchgasm::Search::Condition.new(:does_not_equal, Account, Account.columns_hash["id"])
    condition.value = [1,2,3,4,5]
    assert_equal condition.sanitize, ["\"accounts\".\"id\" NOT IN (1,2,3,4,5)"]
    
    condition = BinaryLogic::Searchgasm::Search::Condition.new(:begins_with, Account, Account.columns_hash["name"])
    condition.value = "Binary"
    assert_equal condition.sanitize, ["\"accounts\".\"name\" LIKE ?", "Binary%"]
    
    condition = BinaryLogic::Searchgasm::Search::Condition.new(:contains, Account, Account.columns_hash["name"])
    condition.value = "Binary"
    assert_equal condition.sanitize, ["\"accounts\".\"name\" LIKE ?", "%Binary%"]
    
    condition = BinaryLogic::Searchgasm::Search::Condition.new(:ends_with, Account, Account.columns_hash["name"])
    condition.value = "Binary"
    assert_equal condition.sanitize, ["\"accounts\".\"name\" LIKE ?", "%Binary"]
    
    condition = BinaryLogic::Searchgasm::Search::Condition.new(:greater_than, Account, Account.columns_hash["id"])
    condition.value = 2
    assert_equal condition.sanitize, ["\"accounts\".\"id\" > ?", 2]
    
    condition = BinaryLogic::Searchgasm::Search::Condition.new(:greater_than_or_equal_to, Account, Account.columns_hash["id"])
    condition.value = 2
    assert_equal condition.sanitize, ["\"accounts\".\"id\" >= ?", 2]
    
    condition = BinaryLogic::Searchgasm::Search::Condition.new(:keywords, Account, Account.columns_hash["name"])
    condition.value = "freedom yeah, freedom YEAH right"
    assert_equal condition.sanitize, ["\"accounts\".\"name\" LIKE ? AND \"accounts\".\"name\" LIKE ? AND \"accounts\".\"name\" LIKE ?", "%freedom%", "%yeah%", "%right%"]
    
    condition = BinaryLogic::Searchgasm::Search::Condition.new(:keywords, Account, Account.columns_hash["name"])
    condition.value = "$^&*()!"
    assert_equal condition.sanitize, [""]
    
    condition = BinaryLogic::Searchgasm::Search::Condition.new(:less_than, Account, Account.columns_hash["id"])
    condition.value = 2
    assert_equal condition.sanitize, ["\"accounts\".\"id\" < ?", 2]
    
    condition = BinaryLogic::Searchgasm::Search::Condition.new(:less_than_or_equal_to, Account, Account.columns_hash["id"])
    condition.value = 2
    assert_equal condition.sanitize, ["\"accounts\".\"id\" <= ?", 2]
    
    assert_raise(ArgumentError) { BinaryLogic::Searchgasm::Search::Condition.new(:descendent_of, Account, nil) }
    
    condition = BinaryLogic::Searchgasm::Search::Condition.new(:child_of, User, nil)
    condition.value = 1
    assert_equal condition.sanitize, ["\"users\".\"parent_id\" = ?", 1]
    
    condition = BinaryLogic::Searchgasm::Search::Condition.new(:sibling_of, User, nil)
    condition.value = 2
    assert_equal condition.sanitize, ["\"users\".\"parent_id\" = ?", 1]
    
    condition = BinaryLogic::Searchgasm::Search::Condition.new(:descendent_of, User, nil)
    condition.value = 1
    assert_equal condition.sanitize, ["\"users\".\"id\" = ? OR \"users\".\"id\" = ?", 2, 3]
    
    condition = BinaryLogic::Searchgasm::Search::Condition.new(:inclusive_descendent_of, User, nil)
    condition.value = 1
    assert_equal condition.sanitize, ["(\"users\".\"id\" = ?) OR (\"users\".\"id\" = ? OR \"users\".\"id\" = ?)", 1, 2, 3]
  end
  
  def test_value
  end
  
end
