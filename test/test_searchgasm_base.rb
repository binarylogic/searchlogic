require File.dirname(__FILE__) + '/test_helper.rb'

class TestSearchgasmBase < Test::Unit::TestCase
  fixtures :accounts, :users, :orders
  
  def setup
    setup_db
    load_fixtures
  end
  
  def teardown
    teardown_db
  end
  
  def test_initialize
    search = BinaryLogic::Searchgasm::Search::Base.new(Account, :conditions => {:name_like => "binary"}, :page => 2, :limit => 10, :readonly => true)
    assert_equal Account, search.klass
    assert_equal "binary", search.conditions.name_like
    assert_equal 2, search.page
    assert_equal 10, search.limit
    assert_equal true, search.readonly
  end
  
  def test_setting_first_level_options
    search = BinaryLogic::Searchgasm::Search::Base.new(Account)
    
    search.include = :users
    assert_equal :users, search.include
    
    search.joins = "test"
    assert_equal "test", search.joins
    
    search.page = 5
    assert_equal 1, search.page # haven't set a limit yet
    assert_equal nil, search.offset
    
    search.limit = 20
    assert_equal search.limit, 20
    assert_equal search.per_page, 20
    assert_equal search.page, 5
    assert_equal search.offset, 100
    
    search.offset = 50
    assert_equal search.offset, 50
    assert_equal search.page, 3
    
    search.per_page = 2
    assert_equal search.per_page, 2
    assert_equal search.limit, 2
    assert_equal search.page, 25
    assert_equal search.offset, 50
    
    search.order = "name ASC"
    assert_equal search.order, "name ASC"
    
    search.select = "name"
    assert_equal search.select, "name"
    
    search.readonly = true
    assert_equal search.readonly, true
    
    search.group = "name"
    assert_equal search.group, "name"
    
    search.from = "accounts"
    assert_equal search.from, "accounts"
    
    search.lock = true
    assert_equal search.lock, true
  end
  
  def test_conditions
    search = BinaryLogic::Searchgasm::Search::Base.new(Account)
    assert_kind_of BinaryLogic::Searchgasm::Search::Conditions, search.conditions
    assert_equal search.conditions.klass, Account
    
    search.conditions = {:name_like => "Binary"}
    assert_kind_of BinaryLogic::Searchgasm::Search::Conditions, search.conditions
    
    conditions = BinaryLogic::Searchgasm::Search::Conditions.new(Account, :id_greater_than => 8)
    search.conditions = conditions
    assert_equal conditions, search.conditions
  end
  
  def test_include
    
  end
  
  def test_limit
    
  end
  
  def test_options
    
  end
  
  def test_order_as
    
  end
  
  def test_order_by
    
  end
  
  def test_page
    
  end
  
  def test_sanitize
    search = BinaryLogic::Searchgasm::Search::Base.new(Account)
    search.per_page = 2
    search.conditions.name_like = "Binary"
    search.conditions.users.id_greater_than = 2
    search.page = 3
    search.readonly = true
    assert_equal search.sanitize, {:include => :users, :offset => 6, :readonly => true, :conditions => ["(\"accounts\".\"name\" LIKE ?) AND (\"users\".\"id\" > ?)", "%Binary%", 2], :limit => 2 }
  end
  
  def test_scope
    
  end
  
  def test_searching
    search = BinaryLogic::Searchgasm::Search::Base.new(Account)
    search.conditions.name_like = "Binary"
    assert_equal search.all, [Account.find(1), Account.find(3)]
    assert_equal search.find(:all), [Account.find(1), Account.find(3)]
    assert_equal search.first, Account.find(1)
    assert_equal search.find(:first), Account.find(1)
    
    search.per_page = 20
    search.page = 2
    
    assert_equal search.all, []
    assert_equal search.find(:all), []
    assert_equal search.first, nil
    assert_equal search.find(:first), nil
        
    search.per_page = 0
    search.page = nil
    search.conditions.users.first_name_contains = "Ben"
    search.conditions.users.orders.description_keywords = "products, &*ap#ple $%^&*"
    assert_equal search.all, [Account.find(1)]
    assert_equal search.find(:all), [Account.find(1)]
    assert_equal search.first, Account.find(1)
    assert_equal search.find(:first), Account.find(1)
  end
  
  def test_calculations
    search = BinaryLogic::Searchgasm::Search::Base.new(Account)
    search.conditions.name_like = "Binary"
    assert_equal 2, search.average('id')
    assert_equal 2, search.calculate(:avg, 'id')
    assert_equal 3, search.calculate(:max, 'id')
    assert_equal 2, search.count
    assert_equal 3, search.maximum('id')
    assert_equal 1, search.minimum('id')
    assert_equal 4, search.sum('id')
  end
  
  def test_protection
    assert_raise(ArgumentError) { Account.build_search(:conditions => "(DELETE FROM users)", :page => 2, :per_page => 15) }
    BinaryLogic::Searchgasm::Search::Base::VULNERABLE_OPTIONS.each { |option| assert_raise(ArgumentError) { Account.build_search(option => "(DELETE FROM users)") } }
    
    assert_nothing_raised { Account.build_search!(:conditions => "(DELETE FROM users)", :page => 2, :per_page => 15) }
    BinaryLogic::Searchgasm::Search::Base::VULNERABLE_OPTIONS.each { |option| assert_nothing_raised { Account.build_search!(option => "(DELETE FROM users)") } }
    
    account = Account.first
    
    assert_raise(ArgumentError) { account.users.build_search(:conditions => "(DELETE FROM users)", :page => 2, :per_page => 15) }
    BinaryLogic::Searchgasm::Search::Base::VULNERABLE_OPTIONS.each { |option| assert_raise(ArgumentError) { account.users.build_search(option => "(DELETE FROM users)") } }
    
    assert_nothing_raised { account.users.build_search!(:conditions => "(DELETE FROM users)", :page => 2, :per_page => 15) }
    BinaryLogic::Searchgasm::Search::Base::VULNERABLE_OPTIONS.each { |option| assert_nothing_raised { account.users.build_search!(option => "(DELETE FROM users)") } }
  end
end
