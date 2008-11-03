require File.dirname(__FILE__) + '/test_helper.rb'

class TestConditionTypes < Test::Unit::TestCase
  def test_sanitize
    condition = Searchlogic::Condition::BeginsWith.new(Account, :column => Account.columns_hash["name"])
    condition.value = "Binary"
    assert_equal ["\"accounts\".\"name\" LIKE ?", "Binary%"], condition.sanitize
    
    condition = Searchlogic::Condition::Blank.new(Account, :column => Account.columns_hash["id"])
    condition.value = "true"
    assert_equal "\"accounts\".\"id\" IS NULL or \"accounts\".\"id\" = '' or \"accounts\".\"id\" = false", condition.sanitize
    
    condition = Searchlogic::Condition::Blank.new(Account, :column => Account.columns_hash["id"])
    condition.value = "false"
    assert_equal "\"accounts\".\"id\" IS NOT NULL and \"accounts\".\"id\" != '' and \"accounts\".\"id\" != false", condition.sanitize
    
    condition = Searchlogic::Condition::Blank.new(Account, :column => Account.columns_hash["id"])
    condition.value = true
    assert_equal "\"accounts\".\"id\" IS NULL or \"accounts\".\"id\" = '' or \"accounts\".\"id\" = false", condition.sanitize
    
    condition = Searchlogic::Condition::Blank.new(Account, :column => Account.columns_hash["id"])
    condition.value = false
    assert_equal "\"accounts\".\"id\" IS NOT NULL and \"accounts\".\"id\" != '' and \"accounts\".\"id\" != false", condition.sanitize
    
    condition = Searchlogic::Condition::Blank.new(Account, :column => Account.columns_hash["id"])
    condition.value = nil
    assert_equal nil, condition.sanitize
    
    condition = Searchlogic::Condition::Blank.new(Account, :column => Account.columns_hash["id"])
    condition.value = ""
    assert_equal nil, condition.sanitize
    
    condition = Searchlogic::Condition::ChildOf.new(User)
    condition.value = User.first.id
    assert_equal ["\"users\".\"parent_id\" = ?", User.first.id], condition.sanitize
    
    condition = Searchlogic::Condition::ChildOf.new(User)
    condition.value = User.first
    assert_equal ["\"users\".\"parent_id\" = ?", User.first.id], condition.sanitize
    
    condition = Searchlogic::Condition::DescendantOf.new(User)
    condition.value = User.find(1)
    assert_equal ["\"users\".\"id\" = ? OR \"users\".\"id\" = ?", 2, 3], condition.sanitize
    
    condition = Searchlogic::Condition::EndsWith.new(Account, :column => Account.columns_hash["name"])
    condition.value = "Binary"
    assert_equal ["\"accounts\".\"name\" LIKE ?", "%Binary"], condition.sanitize
    
    condition = Searchlogic::Condition::Equals.new(Account, :column => Account.columns_hash["id"])
    condition.value = 12
    assert_equal ["\"accounts\".\"id\" = ?", 12], condition.sanitize
    
    condition = Searchlogic::Condition::Equals.new(Account, :column => Account.columns_hash["id"])
    condition.value = [1,2,3,4]
    assert_equal ["\"accounts\".\"id\" IN (?)", [1, 2, 3, 4]], condition.sanitize
    
    condition = Searchlogic::Condition::Equals.new(Account, :column => Account.columns_hash["id"])
    condition.value = (1..10)
    assert_equal ["\"accounts\".\"id\" BETWEEN ? AND ?", 1, 10], condition.sanitize
    
    condition = Searchlogic::Condition::GreaterThan.new(Account, :column => Account.columns_hash["id"])
    condition.value = 2
    assert_equal ["\"accounts\".\"id\" > ?", 2], condition.sanitize
    
    condition = Searchlogic::Condition::GreaterThanOrEqualTo.new(Account, :column => Account.columns_hash["id"])
    condition.value = 2
    assert_equal ["\"accounts\".\"id\" >= ?", 2], condition.sanitize
    
    condition = Searchlogic::Condition::InclusiveDescendantOf.new(User)
    condition.value = User.find(1)
    assert_equal ["(\"users\".\"id\" = ?) OR (\"users\".\"id\" = ? OR \"users\".\"id\" = ?)", 1, 2, 3], condition.sanitize
    
    condition = Searchlogic::Condition::Like.new(Account, :column => Account.columns_hash["name"])
    condition.value = "Binary and blah"
    assert_equal ["\"accounts\".\"name\" LIKE ?", "%Binary and blah%"], condition.sanitize
    
    condition = Searchlogic::Condition::Nil.new(Account, :column => Account.columns_hash["id"])
    condition.value = true
    assert_equal "\"accounts\".\"id\" IS NULL", condition.sanitize
    
    condition = Searchlogic::Condition::Nil.new(Account, :column => Account.columns_hash["id"])
    condition.value = false
    assert_equal "\"accounts\".\"id\" IS NOT NULL", condition.sanitize
    
    condition = Searchlogic::Condition::Nil.new(Account, :column => Account.columns_hash["id"])
    condition.value = "true"
    assert_equal "\"accounts\".\"id\" IS NULL", condition.sanitize
    
    condition = Searchlogic::Condition::Nil.new(Account, :column => Account.columns_hash["id"])
    condition.value = "false"
    assert_equal "\"accounts\".\"id\" IS NOT NULL", condition.sanitize
    
    condition = Searchlogic::Condition::Nil.new(Account, :column => Account.columns_hash["id"])
    condition.value = nil
    assert_equal nil, condition.sanitize
    
    condition = Searchlogic::Condition::Nil.new(Account, :column => Account.columns_hash["id"])
    condition.value = ""
    assert_equal nil, condition.sanitize
    
    condition = Searchlogic::Condition::NotEqual.new(Account, :column => Account.columns_hash["id"])
    condition.value = 12
    assert_equal ["\"accounts\".\"id\" != ?", 12], condition.sanitize
    
    condition = Searchlogic::Condition::NotEqual.new(Account, :column => Account.columns_hash["id"])
    condition.value = [1,2,3,4]
    assert_equal ["\"accounts\".\"id\" NOT IN (?)", [1, 2, 3, 4]], condition.sanitize
    
    condition = Searchlogic::Condition::NotEqual.new(Account, :column => Account.columns_hash["id"])
    condition.value = (1..10)
    assert_equal ["\"accounts\".\"id\" NOT BETWEEN ? AND ?", 1, 10], condition.sanitize
    
    condition = Searchlogic::Condition::NotNil.new(Account, :column => Account.columns_hash["created_at"])
    condition.value = "1"
    assert_equal "\"accounts\".\"created_at\" IS NOT NULL", condition.sanitize
    condition.value = "false"
    assert_equal "\"accounts\".\"created_at\" IS NULL", condition.sanitize
    
    condition = Searchlogic::Condition::Keywords.new(Account, :column => Account.columns_hash["name"])
    condition.value = "freedom yeah, freedom YEAH right"
    assert_equal ["\"accounts\".\"name\" LIKE ? AND \"accounts\".\"name\" LIKE ? AND \"accounts\".\"name\" LIKE ?", "%freedom%", "%yeah%", "%right%"], condition.sanitize
    
    condition = Searchlogic::Condition::Keywords.new(Account, :column => Account.columns_hash["name"])
    condition.value = "%^$*(^$)"
    assert_equal nil, condition.sanitize
    
    condition = Searchlogic::Condition::Keywords.new(Account, :column => Account.columns_hash["name"])
    condition.value = "%^$*(^$) àáâãäåßéèêëìíîïñòóôõöùúûüýÿ"
    assert_equal ["\"accounts\".\"name\" LIKE ?", "%àáâãäåßéèêëìíîïñòóôõöùúûüýÿ%"], condition.sanitize
    
    condition = Searchlogic::Condition::LessThan.new(Account, :column => Account.columns_hash["id"])
    condition.value = 2
    assert_equal ["\"accounts\".\"id\" < ?", 2], condition.sanitize
    
    condition = Searchlogic::Condition::LessThanOrEqualTo.new(Account, :column => Account.columns_hash["id"])
    condition.value = 2
    assert_equal ["\"accounts\".\"id\" <= ?", 2], condition.sanitize
    
    condition = Searchlogic::Condition::SiblingOf.new(User)
    condition.value = User.find(2)
    assert_equal ["(\"users\".\"id\" != ?) AND (\"users\".\"parent_id\" = ?)", 2, 1], condition.sanitize
  end
end
