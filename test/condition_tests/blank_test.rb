require File.dirname(__FILE__) + '/../test_helper.rb'

module ConditionTests
  class BlankTest < ActiveSupport::TestCase
    def test_sanitize
      condition = Searchlogic::Condition::Blank.new(Account, :column => Account.columns_hash["id"])
      condition.value = "true"
      assert_equal "(\"accounts\".\"id\" IS NULL or \"accounts\".\"id\" = '')", condition.sanitize
    
      condition = Searchlogic::Condition::Blank.new(Account, :column => Account.columns_hash["id"])
      condition.value = "false"
      assert_equal "(\"accounts\".\"id\" IS NOT NULL and \"accounts\".\"id\" != '')", condition.sanitize
    
      condition = Searchlogic::Condition::Blank.new(Account, :column => Account.columns_hash["active"])
      condition.value = true
      assert_equal "(\"accounts\".\"active\" IS NULL or \"accounts\".\"active\" = '' or \"accounts\".\"active\" = false)", condition.sanitize
    
      condition = Searchlogic::Condition::Blank.new(Account, :column => Account.columns_hash["active"])
      condition.value = false
      assert_equal "(\"accounts\".\"active\" IS NOT NULL and \"accounts\".\"active\" != '' and \"accounts\".\"active\" != false)", condition.sanitize
    
      condition = Searchlogic::Condition::Blank.new(Account, :column => Account.columns_hash["id"])
      condition.value = nil
      assert_nil condition.sanitize
    
      condition = Searchlogic::Condition::Blank.new(Account, :column => Account.columns_hash["id"])
      condition.value = ""
      assert_nil condition.sanitize
    end
  end
end