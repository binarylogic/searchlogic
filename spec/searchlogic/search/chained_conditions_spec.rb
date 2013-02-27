require 'spec_helper'

describe Searchlogic::SearchExt::ChainedConditions do 
  before(:each) do 
    User.create(:name=>"James", :age =>20, :username => "jvans1", :email => "jvannem@gmail.com" )
    User.create(:name=>"James Vanneman", :age =>21, :username => "jvans1")
    User.create(:name => "Tren")
    User.create(:name=>"Ben")
    Order.create(:total=> 22, :title => "jvans1", :user_id => 3)
    Order.create(:total=> 20, :title => "jvans1", :user_id => 2)
    Order.create(:total=> 19, :title => "jvans1", :user_id => 5)
    Order.create(:total=> 26, :user_id => 3)
    Order.create(:total=> 21, :user_id => 6)

  end
  context "#process_scopes" do 
    context "ordering" do 
      it "should return nil if we aren't ordering" do
        search = Order.search
        search.ordering_by.should be_nil
      end

      it "should return the column name for ascending" do
        search = User.search(:order => "ascend_by_first_name")
        search.ordering_by.should eq("first_name")
      end

      it "ascend's by" do
        search = Order.searchlogic(:order => "ascend_by_total")
        orders = search.all
        orders.count.should eq(5)
        orders.map(&:total).should eq([19,20,21,22,26])
      end

      it "descend's by" do
        search = Order.searchlogic(:order => :descend_by_total)
        orders = search.all
        orders.count.should eq(5)
        orders.map(&:total).should eq([26,22,21,20,19])
      end

      it "ordering containing other conditions" do 
        search = Order.searchlogic( :title => "jvans1", "order" => "descend_by_total", :user_id_gt => 2)
        orders = search.all
        orders.count.should eq(2)
        orders.map(&:total).should eq([22, 19])
      end

      it "accepts symbols as arguements" do 
        search = Order.searchlogic(:order => :descend_by_id)
        orders = search.all
        orders.count.should eq(5)
        orders.map(&:id).should eq([5,4 ,3, 2, 1])
      end
    end
  end

  it "chains scopes" do
    search = User.search(:name_like => "James")
    search.all.count.should eq(2)
    search.age_gt(20)
    search.all.count.should eq(1)
  end 

  it "chains multiple scopes" do 
    search = User.search
    search.all.count.should eq(4)
    search.name_like("James").age_eq(20)
    search.all.count.should eq(1)
    search.map(&:name).should eq(["James"])
  end


  it "finds with blank assignment" do 
    search = User.searchlogic(:username_blank => true)
    search.count.should eq(2)
    search.map(&:name).should eq(["Tren", "Ben"])

  end
  it "doesn't remove conditions from object" do 
    search = User.searchlogic
    search.name_contains = "James"
    search.age_lt = 21
    search.username = "jvans1"
    search.email = nil 
    cond_hash1 = search.conditions
    james = search.all 
    cond_hash2 = search.conditions
    cond_hash1.should eq(cond_hash2)
  end

  it "Calling All without conditions returns all users" do 
    search = User.searchlogic
    search.all.count.should eq(4)
  end
  
  it "returns users with one condition set" do 
    search = User.searchlogic(:age_lt => 21)
    james = search.all 
    james.count.should eq(1)
    james.map(&:name).should eq(["James"])
  end

  context "no argument methods" do 
    it "returns all users with non nil username " do 
      User.all.count.should eq(4)
      search = User.searchlogic(:username_not_nil => true)
      search.all.count.should eq(2)
      search.map(&:name).should eq(["James", "James Vanneman"])
    end
    it "returns all users with nil username when value set to false" do 
      search = User.searchlogic(:username_not_nil => false)
      search.all.count.should eq(2)
      search.map(&:name).should eq(["Tren", "Ben"])
    end

    it "retuns all users with nil username" do 
      User.all.count.should eq(4)
      search = User.searchlogic(:username_nil => true)
      search.all.count.should eq(2)
      search.map(&:name).should eq(["Tren", "Ben"])
    end

    it "returns all users without nil username when value set to false" do 
      search = User.searchlogic(:username_nil => false)
      search.all.count.should eq(2)
      search.map(&:name).should eq(["James", "James Vanneman"])
    end

    it "returns all users with blank name" do 
      search = User.searchlogic(:username_blank => true)
      search.all.count.should eq(2)
      search.map(&:name).should eq(["Tren", "Ben"])
    end

    it "returns all users without blank names when value set to false" do 
      search = User.searchlogic(:username_blank => false)
      search.all.count.should eq(2)
      search.map(&:name).should eq(["James", "James Vanneman"])
    end
    it "returns all users with blank name" do 
      search = User.searchlogic(:username_not_blank => true)
      search.all.count.should eq(2)
      search.map(&:name).should eq(["James", "James Vanneman"])
    end
    
    it "returns all users without blank names when value set to false" do 
      search = User.searchlogic(:username_not_blank => false)
      search.all.count.should eq(2)
      search.map(&:name).should eq(["Tren", "Ben"])
    end
    it "returns all users with blank name with string" do 
      search = User.searchlogic(:username_not_blank => "true")
      search.all.count.should eq(2)
      search.map(&:name).should eq(["James", "James Vanneman"])
    end
    
    it "returns all users without blank names when value set to false with string" do 
      search = User.searchlogic(:username_not_blank => "false")
      search.all.count.should eq(2)
      search.map(&:name).should eq(["Tren", "Ben"])
    end    
  end
end