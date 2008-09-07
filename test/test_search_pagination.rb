require File.dirname(__FILE__) + '/test_helper.rb'

class TestSearchPagination < Test::Unit::TestCase
  fixtures :accounts, :users, :orders
  
  def setup
    setup_db
    load_fixtures
  end
  
  def teardown
    teardown_db
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
end
