require File.dirname(__FILE__) + '/test_helper.rb'

class TestActiveRecordAssociations < Test::Unit::TestCase
  fixtures :accounts, :users, :orders
  
  def setup
    setup_db
    load_fixtures
  end
  
  def teardown
    teardown_db
  end
  
  def test_build_search
    search = Account.find(1).users.build_search
    assert_kind_of Searchgasm::Search::Base, search
    assert_equal User, search.klass
    assert_equal "\"users\".account_id = 1", search.conditions.scope
    
    search.conditions.first_name_contains = "Ben"
    assert_equal({:conditions => ["(\"users\".\"first_name\" LIKE ?) AND (\"users\".account_id = 1)", "%Ben%"]}, search.sanitize)
  end
  
  def test_searching
    assert_equal [User.find(1)], Account.find(1).users.all(:conditions => {:first_name_begins_with => "Ben"})
    assert_equal [User.find(1)], Account.find(1).users.find(:all, :conditions => {:first_name_begins_with => "Ben"})
    assert_equal User.find(1), Account.find(1).users.first(:conditions => {:first_name_begins_with => "Ben"})
    assert_equal User.find(1), Account.find(1).users.find(:first, :conditions => {:first_name_begins_with => "Ben"})
    assert_equal [], Account.find(1).users.all(:conditions => {:first_name_begins_with => "Ben"}, :per_page => 20, :page => 5)
  end
  
  def test_calculations
    assert_equal 1, Account.find(1).users.count(:conditions => {:first_name_begins_with => "Ben"})
    assert_equal 1, Account.find(1).users.sum("id", :conditions => {:first_name_begins_with => "Ben"})
    assert_equal 1, Account.find(1).users.average("id", :conditions => {:first_name_begins_with => "Ben"})
  end
end
