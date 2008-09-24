require File.dirname(__FILE__) + '/test_helper.rb'

class TestActiveRecordAssociations < Test::Unit::TestCase
  def test_has_many
    search = Account.find(1).users.new_search
    assert_kind_of Searchgasm::Search::Base, search
    assert_equal User, search.klass
    assert_equal({:conditions => "\"users\".account_id = 1"}, search.scope)
    
    assert_equal User.find(1, 3), search.all
    assert_equal User.find(1), search.first
    assert_equal 2, search.average("id")
    assert_equal 2, search.count
    
    search.conditions.first_name_contains = "Ben"
    
    assert_equal [User.find(1)], search.all
    assert_equal User.find(1), search.first
    assert_equal 1, search.average("id")
    assert_equal 1, search.count
    
    assert_equal 2, Account.find(1).users.count
    assert_equal 1, Account.find(1).users.all(:conditions => {:first_name_contains => "Ben"}).size
    assert_equal 0, Account.find(1).users.all(:conditions => {:first_name_contains => "No one"}).size
    assert_equal 1, Account.find(1).users.sum("id", :conditions => {:first_name_contains => "Ben"})
    assert_equal 0, Account.find(1).users.sum("id", :conditions => {:first_name_contains => "No one"})
    assert_equal 1, Account.find(1).users.average("id", :conditions => {:first_name_contains => "Ben"})
  end
  
  def test_has_many_through
    search = Account.find(1).orders.new_search
    assert_kind_of Searchgasm::Search::Base, search
    assert_equal Order, search.klass
    assert_equal({:joins => "INNER JOIN users ON orders.user_id = users.id   ", :conditions => "(\"users\".account_id = 1)"}, search.scope)
    
    assert_equal [Order.find(1)], search.all
    assert_equal Order.find(1), search.first
    assert_equal 1, search.average("id")
    assert_equal 1, search.count
    
    search.conditions.total_gt = 100
    
    assert_equal [Order.find(1)], search.all
    assert_equal Order.find(1), search.first
    assert_equal 1, search.average("id")
    assert_equal 1, search.count
    
    assert_equal 1, Account.find(1).orders.count
    assert_equal 1, Account.find(1).orders.all(:conditions => {:total_gt => 100}).size
    assert_equal 0, Account.find(1).orders.all(:conditions => {:total_gt => 1000}).size
    assert_equal 1, Account.find(1).orders.sum("id", :conditions => {:total_gt => 100})
    assert_equal 0, Account.find(1).orders.sum("id", :conditions => {:total_gt => 1000})
    assert_equal 1, Account.find(1).orders.average("id", :conditions => {:total_gt => 100})
  end
  
  def test_habtm
    search = UserGroup.find(1).users.new_search
    assert_kind_of Searchgasm::Search::Base, search
    assert_equal User, search.klass
    assert_equal({:conditions => "\"user_groups_users\".user_group_id = 1 ", :joins => "INNER JOIN \"user_groups_users\" ON \"users\".id = \"user_groups_users\".user_id"}, search.scope)
    
    assert_equal User.find(1, 2), search.all
    assert_equal User.find(1), search.first
    assert_equal 1.5, search.average("id")
    assert_equal 2, search.count
    
    search.conditions.first_name_contains = "Ben"
        
    assert_equal [User.find(1)], search.all
    assert_equal User.find(1), search.first
    assert_equal 1, search.average("id")
    assert_equal 1, search.count
    
    assert_equal 2, UserGroup.find(1).users.count
    assert_equal 1, UserGroup.find(1).users.all(:conditions => {:first_name_contains => "Ben"}).size
    assert_equal 0, UserGroup.find(1).users.all(:conditions => {:first_name_contains => "No one"}).size
    assert_equal 1, UserGroup.find(1).users.sum("id", :conditions => {:first_name_contains => "Ben"})
    assert_equal 0, UserGroup.find(1).users.sum("id", :conditions => {:first_name_contains => "No one"})
    assert_equal 1, UserGroup.find(1).users.average("id", :conditions => {:first_name_contains => "Ben"})
  end
end
