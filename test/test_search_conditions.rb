require File.dirname(__FILE__) + '/test_helper.rb'

class TestSearchConditions < Test::Unit::TestCase
  def test_conditions
    search = Account.new_search
    assert_kind_of Searchgasm::Conditions::Base, search.conditions
    assert_equal search.conditions.klass, Account
  
    search.conditions = {:name_like => "Binary"}
    assert_kind_of Searchgasm::Conditions::Base, search.conditions
    
    search = Account.new_search(:conditions => {:name_like => "Ben"})
    assert_equal({:name_contains => "Ben"}, search.conditions.conditions)
  end
  
  def test_auto_joins
    search = Account.new_search
    search.conditions = {:name_like => "Binary"}
    assert_equal nil, search.auto_joins
    search.conditions.users.first_name_like = "Ben"
    assert_equal :users, search.auto_joins
    search.conditions.reset_users!
    assert_equal nil, search.auto_joins
  end
  
  def test_joins
    search = Account.new_search
    search.conditions = {:id_lte => 2, :users => {:first_name_like => "Ben"}}
    assert_equal :users, search.joins
    assert_equal [Account.find(1)], search.all
    search.conditions.any = true
    assert_equal " LEFT OUTER JOIN \"users\" ON users.account_id = accounts.id ", search.joins
    assert_equal Account.find(1, 2), search.all
  end
  
  def test_sanitize
    # This is tested in test_search_base
  end
end