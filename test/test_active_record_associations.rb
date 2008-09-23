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
    assert_equal({:conditions => "\"users\".account_id = 1"}, search.scope)
    
    search.conditions.first_name_contains = "Ben"
    assert_equal({:conditions => ["\"users\".\"first_name\" LIKE ?", "%Ben%"]}, search.sanitize)
  end
  
  def test_searching
    assert_equal [User.find(1)], Account.find(1).users.all(:conditions => {:first_name_begins_with => "Ben"})
    assert_equal [User.find(1)], Account.find(1).users.find(:all, :conditions => {:first_name_begins_with => "Ben"})
    assert_equal User.find(1), Account.find(1).users.first(:conditions => {:first_name_begins_with => "Ben"})
    assert_equal User.find(1), Account.find(1).users.find(:first, :conditions => {:first_name_begins_with => "Ben"})
    assert_equal [], Account.find(1).users.all(:conditions => {:first_name_begins_with => "Ben"}, :per_page => 20, :page => 5)
    
    search = Account.find(1).users.new_search
    assert_equal User.find(1, 3), search.all
    assert_equal User.find(1), search.first
  end
  
  def test_calculations
    assert_equal 1, Account.find(1).users.count(:conditions => {:first_name_begins_with => "Ben"})
    assert_equal 1, Account.find(1).users.sum("id", :conditions => {:first_name_begins_with => "Ben"})
    assert_equal 1, Account.find(1).users.average("id", :conditions => {:first_name_begins_with => "Ben"})
  end
  
  def test_has_many_through
    assert_equal 1, Account.find(1).orders.count
    assert_equal 1, Account.find(1).orders.all(:conditions => {:total_gt => 100}).size
    assert_equal 0, Account.find(1).orders.all(:conditions => {:total_gt => 1000}).size
    assert_equal 1, Account.find(1).orders.sum("id", :conditions => {:total_gt => 100})
    assert_equal 0, Account.find(1).orders.sum("id", :conditions => {:total_gt => 1000})
    assert_equal 1, Account.find(1).orders.average("id", :conditions => {:total_gt => 100})
    
    search = Account.find(1).orders.new_search
    assert_equal [Order.find(1)], search.all
    assert_equal Order.find(1), search.first
    assert_equal 1, search.average("id")
    assert_equal 1, search.count
  end
  
  def test_habtm
    
  end
end
