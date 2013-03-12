require 'spec_helper'

describe Searchlogic::SearchExt::Delegate do 
  describe "delegates" do 
    before(:each) do 
      @james = User.create(:name=>"James", :age =>20, :username => "jvans1" )
      User.create(:name=>"James Vanneman", :age =>21, :username => "jvans1")
      @tren = User.create(:name => "Tren", :username =>"jvans")
      User.create(:name=>"Ben", :username =>"jvans1")
    end

    context "#delegate" do
      it "delegates to AR relation" do 
        search = User.searchlogic(:username_is => "jvans1")
        search.count.should eq(3)
      end

      it "should delegate the find_* method of active record" do 
        User.find_by_name("James").should eq(@james)
      end

      it "delegates with arguements" do 
        search = User.searchlogic(:username_is => "jvans1")
        james = search.find_by_name("James Vanneman")
        james.name.should eq("James Vanneman")
      end

      it "delegates" do 
        search = User.searchlogic(:name_like => "James")
        james = search.first
        james.name.should eq("James")
      end

      it "delegates scopes on associations" do 
        class User; scope :uname, lambda { name_eq("James") };end
        james = User.create(:name => "James")
        co1 = Company.create(:users =>[james])
        search = Company.search(:users_uname => true)
        search.all.should eq([co1])
      end

      it "should pass on context from a named scope" do 
        class User; scope :my_name, lambda {name_eq("James")};end
        User.my_name.search.all.should eq([@james])
      end

    context "errors" do 
      it "should raise NoConditionError when the method is just a column" do
        search = User.search
        expect{search.age = 10}.to raise_error Searchlogic::ActiveRecordExt::Scopes::NoConditionError
      end    

      it "should raise no method error if method is not recognized" do
        search = User.search 
        expect{search.boogie = 21}.to raise_error NoMethodError

      end
    end

    end

    context "#empty" do 
      it "should respond to empty" do 
        search = Order.search
        search.empty?.should be_true
      end
    end
  end
  describe "scoping" do 
    before(:each) do 
      l1 = LineItem.create(:price=> 10)
      l2 = LineItem.create(:price=> 20)
      l3 = LineItem.create(:price=> 9)
      l4 = LineItem.create(:price=> 12)
      l5 = LineItem.create(:price=> 10)
      l6 = LineItem.create(:price=> 10)
      l7 = LineItem.create(:price=> 10)
      l8 = LineItem.create(:price=> 12)
      l9 = LineItem.create(:price=> 20)
      o1 = Order.create(:total=> 22, :title => "jvans1", :user_id => 3, :line_items => [l1,l3])
      o2 = Order.create(:total=> 20, :title => "jvans1", :user_id => 2, :line_items => [l1,l2] , :name => "jvans1's order")
      o3 = Order.create(:total=> 19, :title => "jvans1", :user_id => 5, :line_items => [l9,l4])
      o4 = Order.create(:total=> 26, :user_id => 3, :line_items => [l5,l6])
      o5 = Order.create(:total=> 21, :user_id => 6, :line_items => [l7,l8])
      @u1 = User.create(:orders=> [o1], :name=>"James", :age =>20, :username => "jvans1", :email => "jvannem@gmail.com" )
      @u2 = User.create(:orders=> [o2], :name=>"James Vanneman", :age =>21, :username => "jvans1")
      @u3 = User.create(:orders=> [o3], :name => "Tren")
      @u4 = User.create(:orders=> [o4, o5], :name=>"Ben")
      Company.create(:users => [@u1], :name => "NEco")
      Company.create(:users => [@u2], :name => "ConciergeLive1")
      Company.create(:users => [@u3, @u4], :name => "ConciergeLive2")
    end
    it "works with scopes and or" do 
      class User; scope :cool, lambda{created_at_after("last year")};end
      search = Company.search(:username_eq_or_name_like => "James", :users_cool => true)
    end
    context "#scope" do
      it "chains scopes" do
        search = User.search(:name_like => "James")
        search.all.count.should eq(2)
        search.age_gt(20)
        search.all.count.should eq(1)
      end 

      it "chains multiple scopes" do 
        search = Order.search
        search.all.count.should eq(5)
        search.title_eq("jvans1").total_lt(22).user_id_eq(2)
        search.all.count.should eq(1)
        search.map(&:name).should eq(["jvans1's order"])
      end

      it "doesn't remove conditions from object" do 
        search = User.searchlogic
        search.name_contains = "James"
        search.age_lt = 21
        search.username_eq = "jvans1"
        search.email_eq = nil 
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

      context "ordering" do 
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

        it "containing other conditions" do 
          search = Order.searchlogic(:title_eq => "jvans1", "order" => "descend_by_total", :user_id_eq_any => [2,3])
          orders = search.all
          orders.count.should eq(2)
          orders.map(&:total).should eq([20, 19])
        end

        it "accepts symbols as arguements" do 
          search = Order.searchlogic(:order => :descend_by_id)
          orders = search.all
          orders.count.should eq(5)
          orders.map(&:id).should eq([5,4 ,3, 2, 1])
        end


        it "finds with blank assignment" do 
          search = User.searchlogic(:username_blank => true)
          search.count.should eq(2)
          search.map(&:name).should eq(["Tren", "Ben"])
        end
      end
      context "associations" do 
        it "chains deeply nested association" do 
          search = Company.search(:users_orders_line_items_price_gt => 10)
          companies = search.all
          companies.count.should eq(2)
          companies.map(&:name).should eq(["ConciergeLive1", "ConciergeLive2"])
        end  
      end
      context "no argument methods" do 
        it "returns all users with non nil username " do 
          User.all.count.should eq(4)
          search = User.searchlogic(:username_not_nil => true)
          search.all.count.should eq(2)
          search.map(&:name).should eq(["James", "James Vanneman"])
        end

        it "can assign nil as value" do 
          User.all.count.should eq(4)
          search = User.searchlogic
          search.username_eq = nil
          search.all.count.should eq(2)
          search.all.should eq([@u3, @u4])
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
  end  
end