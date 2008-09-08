require File.dirname(__FILE__) + '/test_helper.rb'

class TestConditionsProtection < Test::Unit::TestCase
  fixtures :accounts, :users, :orders
  
  def setup
    setup_db
    load_fixtures
  end
  
  def teardown
    teardown_db
  end

  def test_protection
    assert_raise(ArgumentError) { Account.new_conditions("(DELETE FROM users)") }
    assert_nothing_raised { Account.build_conditions!("(DELETE FROM users)") }
    
    account = Account.first
    
    assert_raise(ArgumentError) { account.users.build_conditions("(DELETE FROM users)") }
    assert_nothing_raised { account.users.build_conditions!("(DELETE FROM users)") }
  end
end
