require File.dirname(__FILE__) + '/test_helper.rb'

class TestActiveRecordBase < Test::Unit::TestCase
  fixtures :accounts, :users, :orders
  
  def setup
    setup_db
    load_fixtures
  end
  
  def teardown
    teardown_db
  end
  
  def test_standard_searches
    assert_nothing_raised { Account.all }
    assert_nothing_raised { Account.first }
    assert_nothing_raised { Account.find(:all) }
    assert_nothing_raised { Account.find(:all, :conditions => {:name => "Ben"}) }
    assert_nothing_raised { Account.find(:all, :conditions => ["name = ?", "Ben"]) }
    assert_nothing_raised { Account.find(:all, :conditions => "name = 'Ben'") }
    assert_nothing_raised { Account.find(:first) }
    assert_nothing_raised { Account.find(:all, nil) }
    assert_nothing_raised { Account.find(:all, {}) }
    assert_nothing_raised { Account.count({}) }
    assert_nothing_raised { Account.count(nil) }
    assert_nothing_raised { Account.sum("id") }
    assert_nothing_raised { Account.sum("id", {}) }
  end
  
  def test_valid_find_options
    assert_equal [ :conditions, :include, :joins, :limit, :offset, :order, :select, :readonly, :group, :from, :lock ], ActiveRecord::Base.valid_find_options
  end
  
  def test_build_search
    search = Account.new_search
    assert_kind_of Searchgasm::Search::Base, search
        
    search = Account.build_search(:conditions => {:name_keywords => "awesome"}, :page => 2, :per_page => 15)
    assert_kind_of Searchgasm::Search::Base, search
    assert_equal Account, search.klass
    assert_equal "awesome", search.conditions.name_keywords
    assert_equal 2, search.page
    assert_equal 15, search.per_page
    
    search = Account.new_search(:conditions => {:name_keywords => "awesome"}, :page => 2, :per_page => 15)
    assert_equal Account, search.klass
  end
  
  def test_build_conditions
    search = Account.new_conditions
    assert_kind_of Searchgasm::Conditions::Base, search
    
    search = Account.build_conditions(:name_keywords => "awesome")
    assert_kind_of Searchgasm::Conditions::Base, search
    assert_equal Account, search.klass
    assert_equal "awesome", search.name_keywords

    search = Account.new_conditions(:name_keywords => "awesome")
    assert_equal Account, search.klass
  end
  
  def test_searching
    assert_equal Account.find(1, 3), Account.all(:conditions => {:name_contains => "Binary"})
    assert_equal [Account.find(1)], Account.all(:conditions => {:name_contains => "Binary", :users => {:first_name_starts_with => "Ben"}})
    assert_equal [], Account.all(:conditions => {:name_contains => "Binary", :users => {:first_name_starts_with => "Ben", :last_name => "Mills"}})
    
    read_only_accounts = Account.all(:conditions => {:name_contains => "Binary"}, :readonly => true)
    assert read_only_accounts.first.readonly?
    
    assert_equal Account.find(1, 3), Account.all(:conditions => {:name_contains => "Binary"}, :page => 2)
    assert_equal [], Account.all(:conditions => {:name_contains => "Binary"}, :page => 2, :per_page => 20)
  end
  
  def test_counting
    assert_equal 2, Account.count(:conditions => {:name_contains => "Binary"})
    assert_equal 1, Account.count(:conditions => {:name_contains => "Binary", :users => {:first_name_contains => "Ben"}})
  end
  
  def test_scoping
    assert_equal nil, Account.send(:scope, :find)
  end
end
