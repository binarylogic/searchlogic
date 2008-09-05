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
  
  def test_needed
    assert Searchgasm::Search::Base.needed?(Account, :page => 2, :conditions => {:name => "Ben"})
    assert !Searchgasm::Search::Base.needed?(Account, :conditions => {:name => "Ben"})
    assert Searchgasm::Search::Base.needed?(Account, :limit => 2, :conditions => {:name_contains => "Ben"})
    assert !Searchgasm::Search::Base.needed?(Account, :limit => 2)
    assert Searchgasm::Search::Base.needed?(Account, :per_page => 2)
  end
  
  def test_initialize
    assert_nothing_raised { Searchgasm::Search::Base.new(Account) }
    search = Searchgasm::Search::Base.new(Account, :conditions => {:name_like => "binary"}, :page => 2, :limit => 10, :readonly => true)
    assert_equal Account, search.klass
    assert_equal "binary", search.conditions.name_like
    assert_equal 2, search.page
    assert_equal 10, search.limit
    assert_equal true, search.readonly
  end
  
  def test_setting_first_level_options
    search = Searchgasm::Search::Base.new(Account)
    
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
    assert_equal search.offset, 80
    
    search.offset = 50
    assert_equal search.offset, 50
    assert_equal search.page, 3
    
    search.per_page = 2
    assert_equal search.per_page, 2
    assert_equal search.limit, 2
    assert_equal search.page, 26
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
    search = Searchgasm::Search::Base.new(Account)
    assert_kind_of Searchgasm::Search::Conditions, search.conditions
    assert_equal search.conditions.klass, Account
    
    search.conditions = {:name_like => "Binary"}
    assert_kind_of Searchgasm::Search::Conditions, search.conditions
    
    conditions = Searchgasm::Search::Conditions.new(Account, :id_greater_than => 8)
    search.conditions = conditions
    assert_equal conditions, search.conditions
  end
  
  def test_include
    search = Searchgasm::Search::Base.new(Account)
    assert_equal nil, search.include
    search.conditions.name_contains = "Binary"
    assert_equal nil, search.include
    search.conditions.users.first_name_contains = "Ben"
    assert_equal(:users, search.include)
    search.conditions.users.orders.id_gt = 2
    assert_equal({:users => :orders}, search.include)
    search.conditions.users.reset_orders!
    assert_equal(:users, search.include)
    search.conditions.users.orders.id_gt = 2
    search.conditions.reset_users!
    assert_equal nil, search.include
  end
  
  def test_limit
    search = Searchgasm::Search::Base.new(Account)
    search.limit = 10
    assert_equal 10, search.limit
    search.page = 2
    assert_equal 10, search.offset
    search.limit = 25
    assert_equal 25, search.offset
    assert_equal 2, search.page
    search.page = 5
    assert_equal 5, search.page
    assert_equal 25, search.limit
    search.limit = 3
    assert_equal 12, search.offset
  end
  
  def test_options
  end
  
  def test_order_as
    search = Searchgasm::Search::Base.new(Account)
    assert_equal nil, search.order
    assert_equal "ASC", search.order_as
    assert search.asc?
    
    search.order_as = "DESC"
    assert_equal "DESC", search.order_as
    assert search.desc?
    assert_equal "\"accounts\".\"id\" DESC", search.order
    
    search.order = "id ASC"
    assert_equal "ASC", search.order_as
    assert search.asc?
    assert_equal "id ASC", search.order
    
    search.order = "id DESC"
    assert_equal "DESC", search.order_as
    assert search.desc?
    assert_equal "id DESC", search.order
    
    search.order_by = "name"
    assert_equal "DESC", search.order_as
    assert search.desc?
    assert_equal "\"accounts\".\"name\" DESC", search.order
  end
  
  def test_order_by
    search = Searchgasm::Search::Base.new(Account)
    assert_equal nil, search.order
    assert_equal "id", search.order_by
    
    search.order_by = "first_name"
    assert_equal "first_name", search.order_by
    assert_equal "\"accounts\".\"first_name\" ASC", search.order
    
    search.order_by = "last_name"
    assert_equal "last_name", search.order_by
    assert_equal "\"accounts\".\"last_name\" ASC", search.order
    
    search.order_by = ["first_name", "last_name"]
    assert_equal ["first_name", "last_name"], search.order_by
    assert_equal "\"accounts\".\"first_name\" ASC, \"accounts\".\"last_name\" ASC", search.order
    
    search.order = "created_at DESC"
    assert_equal "created_at", search.order_by
    assert_equal "created_at DESC", search.order
    
    search.order = "\"users\".updated_at ASC"
    assert_equal({"users" => "updated_at"}, search.order_by)
    assert_equal "\"users\".updated_at ASC", search.order
    
    search.order = "`users`.first_name DESC"
    assert_equal({"users" => "first_name"}, search.order_by)
    assert_equal "`users`.first_name DESC", search.order
    
    search.order = "`accounts`.name DESC"
    assert_equal "name", search.order_by
    assert_equal "`accounts`.name DESC", search.order
    
    search.order = "accounts.name DESC"
    assert_equal "name", search.order_by
    assert_equal "accounts.name DESC", search.order
    
    search.order = "`users`.first_name DESC, name DESC, `accounts`.id DESC"
    assert_equal [{"users" => "first_name"}, "name", "id"], search.order_by
    assert_equal "`users`.first_name DESC, name DESC, `accounts`.id DESC", search.order
    
    search.order = "`users`.first_name DESC, `line_items`.id DESC, `accounts`.id DESC"
    assert_equal [{"users" => "first_name"}, "id"], search.order_by
    assert_equal "`users`.first_name DESC, `line_items`.id DESC, `accounts`.id DESC", search.order
    
    search.order = "`line_items`.id DESC"
    assert_equal nil, search.order_by
    assert_equal "`line_items`.id DESC", search.order
  end
  
  def test_page
    search = Searchgasm::Search::Base.new(Account)
    search.page = 2
    assert_equal 1, search.page
    search.per_page = 20
    assert_equal 2, search.page
    search.limit = 0
    assert_equal 1, search.page
    search.per_page = 20
    assert_equal 2, search.page
    search.limit = nil
    assert_equal 1, search.page
  end
  
  def test_next_page
    
  end
  
  def test_prev_page
    
  end
  
  def test_page_count
    
  end
  
  def test_sanitize
    search = Searchgasm::Search::Base.new(Account)
    search.per_page = 2
    search.conditions.name_like = "Binary"
    search.conditions.users.id_greater_than = 2
    search.page = 3
    search.readonly = true
    assert_equal({:include => :users, :offset => 4, :readonly => true, :conditions => ["(\"accounts\".\"name\" LIKE ?) AND (\"users\".\"id\" > ?)", "%Binary%", 2], :limit => 2 }, search.sanitize)
  end
  
  def test_scope
    search = Searchgasm::Search::Base.new(Account)
    search.conditions = "some scope"
    assert_equal "some scope", search.conditions.scope
    search.conditions = nil
    assert_equal nil, search.conditions.scope
    search.conditions = "some scope"
    assert_equal "some scope", search.conditions.scope
    search.conditions = "some scope2"
    assert_equal "some scope2", search.conditions.scope
  end
  
  def test_searching
    search = Searchgasm::Search::Base.new(Account)
    search.conditions.name_like = "Binary"
    assert_equal search.all, [Account.find(1), Account.find(3)]
    assert_equal search.find(:all), [Account.find(1), Account.find(3)]
    assert_equal search.first, Account.find(1)
    assert_equal search.find(:first), Account.find(1)
    
    search.per_page = 20
    search.page = 2
    
    assert_equal [], search.all
    assert_equal [], search.find(:all)
    assert_equal nil, search.first
    assert_equal nil, search.find(:first)
        
    search.per_page = 0
    search.page = nil
    search.conditions.users.first_name_contains = "Ben"
    search.conditions.users.orders.description_keywords = "products, &*ap#ple $%^&*"
    assert_equal [Account.find(1)], search.all
    assert_equal [Account.find(1)], search.find(:all)
    assert_equal Account.find(1), search.first
    assert_equal Account.find(1), search.find(:first)
  end
  
  def test_calculations
    search = Searchgasm::Search::Base.new(Account)
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
    Searchgasm::Search::Base::VULNERABLE_OPTIONS.each { |option| assert_raise(ArgumentError) { Account.build_search(option => "(DELETE FROM users)") } }
    
    assert_nothing_raised { Account.build_search!(:conditions => "(DELETE FROM users)", :page => 2, :per_page => 15) }
    Searchgasm::Search::Base::VULNERABLE_OPTIONS.each { |option| assert_nothing_raised { Account.build_search!(option => "(DELETE FROM users)") } }
    
    account = Account.first
    
    assert_raise(ArgumentError) { account.users.build_search(:conditions => "(DELETE FROM users)", :page => 2, :per_page => 15) }
    Searchgasm::Search::Base::VULNERABLE_OPTIONS.each { |option| assert_raise(ArgumentError) { account.users.build_search(option => "(DELETE FROM users)") } }
    
    assert_nothing_raised { account.users.build_search!(:conditions => "(DELETE FROM users)", :page => 2, :per_page => 15) }
    Searchgasm::Search::Base::VULNERABLE_OPTIONS.each { |option| assert_nothing_raised { account.users.build_search!(option => "(DELETE FROM users)") } }
    
    assert_raise(ArgumentError) { Account.build_search(:order_by => "unknown_column") }
    assert_nothing_raised { Account.build_search!(:order_by => "unknown_column") }
    assert_raise(ArgumentError) { Account.build_search(:order_by => ["name", "unknown_column"]) }
    assert_nothing_raised { Account.build_search!(:order_by => ["name", "unknown_column"]) }
  end
end
