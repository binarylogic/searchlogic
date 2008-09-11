require File.dirname(__FILE__) + '/test_helper.rb'

class TestSearchConditions < Test::Unit::TestCase
  fixtures :accounts, :users, :orders

  def setup
    setup_db
    load_fixtures
  end

  def teardown
    teardown_db
  end

  def test_conditions
    search = Account.new_search
    assert_kind_of Searchgasm::Conditions::Base, search.conditions
    assert_equal search.conditions.klass, Account
  
    search.conditions = {:name_like => "Binary"}
    assert_kind_of Searchgasm::Conditions::Base, search.conditions
  
    conditions = Account.new_conditions(:id_greater_than => 8)
    search.conditions = conditions
    assert_equal conditions, search.conditions
  end
end