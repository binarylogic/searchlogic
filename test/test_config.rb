require File.dirname(__FILE__) + '/test_helper.rb'

class TestConfig < Test::Unit::TestCase
  def test_per_page
    Searchgasm::Config.per_page = 1
    
    assert Account.count > 1
    assert Account.all.size > 1
    assert User.all.size > 1
    assert User.find(:all, :per_page => 1).size == 1
    assert User.new_search.all.size == 1
    assert User.new_search(:per_page => nil).all.size > 1
    
    Searchgasm::Config.per_page = nil
    
    assert Account.count > 1
    assert Account.all.size > 1
    assert User.all.size > 1
    assert User.find(:all, :per_page => 1).size == 1
    assert User.new_search.all.size > 1
    assert User.new_search(:per_page => 1).all.size == 1
  end
  
  # test that config options do not mess up regular AR searches
end