require File.dirname(__FILE__) + '/test_helper.rb'

class TestActiveRecordBase < Test::Unit::TestCase
  def test_standard_find
    assert_equal [1,2,3], Account.all.map(&:id)
    assert_equal 1, Account.first.id
    assert_equal [1,2,3], Account.find(:all).map(&:id)
    assert_equal [1], Account.find(:all, :conditions => {:name => "Binary Logic"}).map(&:id)
    assert_equal [1], Account.find(:all, :conditions => ["name = ?", "Binary Logic"]).map(&:id)
    assert_equal [1], Account.find(:all, :conditions => "name = 'Binary Logic'").map(&:id)
    assert_equal 1, Account.find(:first).id
    assert_equal [1,2,3], Account.find(:all, nil).map(&:id)
    assert_equal [1,2,3], Account.find(:all, {}).map(&:id)
    assert_equal [1,2,3], Account.find(:all, :select => "id, name").map(&:id)
  end
  
  def test_standard_calculations
    assert_equal 3, Account.count({})
    assert_equal 3, Account.count(nil)
    assert_equal 3, Account.count(:limit => 1)
    assert_equal 0, Account.count(:limit => 10, :offset => 10)
    assert_equal 6, Account.sum("id")
    assert_equal 6, Account.sum("id", {})
    assert_equal 2, Account.average("id")
    assert_equal 3, Account.maximum("id")
    assert_equal 1, Account.minimum("id")
  end
  
  def test_valid_ar_options
    assert_equal [ :conditions, :include, :joins, :limit, :offset, :order, :select, :readonly, :group, :from, :lock ], ActiveRecord::Base.valid_find_options
    assert_equal [:conditions, :joins, :order, :select, :group, :having, :distinct, :limit, :offset, :include, :from], ActiveRecord::Base.valid_calculations_options
  end
  
  def test_build_search
    search = Account.new_search(:conditions => {:name_keywords => "awesome"}, :page => 2, :per_page => 15)
    assert_kind_of Searchgasm::Search::Base, search
    assert_equal({}, search.scope)
    assert_equal Account, search.klass
    assert_equal "awesome", search.conditions.name_keywords
    assert_equal 2, search.page
    assert_equal 15, search.per_page
  end
  
  def test_searchgasm_searching
    assert_equal Account.find(1, 3), Account.all(:conditions => {:name_contains => "Binary"})
    assert_equal [Account.find(1)], Account.all(:conditions => {:name_contains => "Binary", :users => {:first_name_starts_with => "Ben"}})
    assert_equal [], Account.all(:conditions => {:name_contains => "Binary", :users => {:first_name_starts_with => "Ben", :last_name => "Mills"}})
    
    read_only_accounts = Account.all(:conditions => {:name_contains => "Binary"}, :readonly => true)
    assert read_only_accounts.first.readonly?
    
    assert_equal Account.find(1, 3), Account.all(:conditions => {:name_contains => "Binary"}, :page => 2)
    assert_equal [], Account.all(:conditions => {:name_contains => "Binary"}, :page => 2, :per_page => 20)
  end
  
  def test_searchgasm_counting
    assert_equal 2, Account.count(:conditions => {:name_contains => "Binary"})
    assert_equal 1, Account.count(:conditions => {:name_contains => "Binary", :users => {:first_name_contains => "Ben"}})
    assert_equal 1, Account.count(:conditions => {:name_contains => "Binary", :users => {:first_name_contains => "Ben"}}, :limit => 10, :offset => 10, :order_by => "id", :group => "id")
  end
  
  def test_scoping
    assert_equal({:conditions => {:name => "Binary"}, :limit => 10, :readonly => true}, Account.send(:with_scope, :find => {:conditions => {:name => "Binary"}, :limit => 10, :readonly => true}) { Account.send(:scope, :find) })
    assert_equal({:conditions => ["\"accounts\".\"name\" LIKE ?", "%Binary%"], :limit => 10, :offset => 20}, Account.send(:with_scope, :find => {:conditions => {:name_contains => "Binary"}, :per_page => 10, :page => 3}) { Account.send(:scope, :find) })
  end
  
  def test_accessible_conditions
    Account.conditions_accessible :name_contains
    assert_equal Set.new(["name_contains"]), Account.accessible_conditions
    Account.conditions_accessible :id_gt
    assert_equal Set.new(["id_gt", "name_contains"]), Account.accessible_conditions
    Account.conditions_accessible :id_gt, :name_contains
    assert_equal Set.new(["id_gt", "name_contains"]), Account.accessible_conditions
    Account.send(:write_inheritable_attribute, :conditions_accessible, nil)
  end
  
  def test_protected_conditions
    Account.conditions_protected :name_contains
    assert_equal Set.new(["name_contains"]), Account.protected_conditions
    Account.conditions_protected :id_gt
    assert_equal Set.new(["id_gt", "name_contains"]), Account.protected_conditions
    Account.conditions_protected :id_gt, :name_contains
    assert_equal Set.new(["id_gt", "name_contains"]), Account.protected_conditions
    Account.send(:write_inheritable_attribute, :conditions_protected, nil)
  end
end
