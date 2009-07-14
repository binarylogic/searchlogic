require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

describe "Search" do
  context "implementation" do
    it "should create a search proxy" do
      User.search(:username => "joe").should be_kind_of(Searchlogic::Search)
    end

    it "should create a search proxy using the same class" do
      User.search.klass.should == User
    end

    it "should pass on the current scope to the proxy" do
      company = Company.create
      user = company.users.create
      search = company.users.search
      search.current_scope.should == company.users.scope(:find)
    end
  end
  
  context "initialization" do
    it "should require a class" do
      lambda { Searchlogic::Search.new }.should raise_error(ArgumentError)
    end
  
    it "should set the conditions" do
      search = User.search(:username => "bjohnson")
      search.conditions.should == {:username => "bjohnson"}
    end
  end
  
  it "should clone properly" do
    company = Company.create
    user1 = company.users.create(:age => 5)
    user2 = company.users.create(:age => 25)
    search1 = company.users.search(:age_gt => 10)
    search2 = search1.clone
    search2.age_gt = 1
    search2.all.should == User.all
    search1.all.should == [user2]
  end
  
  it "should delete the condition" do
    search = User.search(:username_like => "bjohnson")
    search.delete("username_like")
    search.username_like.should be_nil
  end
  
  context "conditions" do
    it "should set the conditions and be accessible individually" do
      search = User.search
      search.conditions = {:username => "bjohnson"}
      search.username.should == "bjohnson"
    end
    
    it "should set the conditions and allow string keys" do
      search = User.search
      search.conditions = {"username" => "bjohnson"}
      search.username.should == "bjohnson"
    end
    
    it "should ignore blank values" do
      search = User.search
      search.conditions = {"username" => ""}
      search.username.should be_nil
    end
    
    it "should ignore blank values in arrays" do
      search = User.search
      search.conditions = {"username_equals_any" => [""]}
      search.username_equals_any.should be_blank
    end
  end
  
  context "condition accessors" do
    it "should allow setting exact columns individually" do
      search = User.search
      search.username = "bjohnson"
      search.username.should == "bjohnson"
    end
    
    it "should allow setting local column conditions individually" do
      search = User.search
      search.username_gt = "bjohnson"
      search.username_gt.should == "bjohnson"
    end
    
    it "should allow chainging conditions" do
      user = User.create(:username => "bjohnson", :age => 20)
      User.create(:username => "bjohnson", :age => 5)
      search = User.search
      search.username_equals("bjohnson").age_gt(10)
      search.all.should == [user]
    end
    
    it "should allow setting association conditions" do
      search = User.search
      search.orders_total_gt = 10
      search.orders_total_gt.should == 10
    end
    
    it "should allow using custom conditions" do
      User.named_scope(:four_year_olds, { :conditions => { :age => 4 } })
      search = User.search
      search.four_year_olds = true
      search.four_year_olds.should == true
      search.proxy_options.should == User.four_year_olds.proxy_options
    end
    
    it "should not merge conflicting conditions into one value" do
      # This class should JUST be a proxy. It should not do anything more than that.
      # A user would be allowed to call both named scopes if they wanted.
      search = User.search
      search.username_greater_than = "bjohnson1"
      search.username_gt = "bjohnson2"
      search.username_greater_than.should == "bjohnson1"
      search.username_gt.should == "bjohnson2"
    end
    
    it "should allow setting custom conditions individually with an arity of 0" do
      User.named_scope(:four_year_olds, :conditions => {:age => 4})
      search = User.search
      search.four_year_olds = true
      search.four_year_olds.should == true
    end
    
    it "should allow setting custom conditions individually with an arity of 1" do
      User.named_scope(:username_should_be, lambda { |u| {:conditions => {:username => u}} })
      search = User.search
      search.username_should_be = "bjohnson"
      search.username_should_be.should == "bjohnson"
    end
    
    it "should not allow setting conditions that are not scopes" do
      search = User.search
      lambda { search.unknown = true }.should raise_error(Searchlogic::Search::UnknownConditionError)
    end
    
    it "should not use the ruby implementation of the id method" do
      search = User.search
      search.id.should be_nil
    end
    
    context "type casting" do
      it "should be a Boolean given true" do
        search = User.search
        search.id_nil = true
        search.id_nil.should == true
      end
      
      it "should be a Boolean given 'true'" do
        search = User.search
        search.id_nil = "true"
        search.id_nil.should == true
      end
      
      it "should be a Boolean given '1'" do
        search = User.search
        search.id_nil = "1"
        search.id_nil.should == true
      end
      
      it "should be a Boolean given false" do
        search = User.search
        search.id_nil = false
        search.id_nil.should == false
      end
      
      it "should be a Boolean given 'false'" do
        search = User.search
        search.id_nil = "false"
        search.id_nil.should == false
      end
      
      it "should be a Boolean given '0'" do
        search = User.search
        search.id_nil = "0"
        search.id_nil.should == false
      end
      
      it "should be an Integer given 1" do
        search = User.search
        search.id_gt = 1
        search.id_gt.should == 1
      end
      
      it "should be an Integer given '1'" do
        search = User.search
        search.id_gt = "1"
        search.id_gt.should == 1
      end
      
      it "should be a Float given 1.0" do
        search = Order.search
        search.total_gt = 1.0
        search.total_gt.should == 1.0
      end
      
      it "should be a Float given '1'" do
        search = Order.search
        search.total_gt = "1"
        search.total_gt.should == 1.0
      end
      
      it "should be a Float given '1.5'" do
        search = Order.search
        search.total_gt = "1.5"
        search.total_gt.should == 1.5
      end
      
      it "should be a Date given 'Jan 1, 2009'" do
        search = Order.search
        search.shipped_on_after = "Jan 1, 2009"
        search.shipped_on_after.should == Date.parse("Jan 1, 2009")
      end
      
      it "should be a Time given 'Jan 1, 2009'" do
        search = Order.search
        search.created_at_after = "Jan 1, 2009"
        search.created_at_after.should == Time.parse("Jan 1, 2009")
      end
      
      it "should be a Time given 'Jan 1, 2009 9:33AM'" do
        search = Order.search
        search.created_at_after = "Jan 1, 2009 9:33AM"
        search.created_at_after.should == Time.parse("Jan 1, 2009 9:33AM")
      end
      
      it "should convert the time to the current zone" do
        search = Order.search
        now = Time.now
        search.created_at_after = now
        search.created_at_after.should == now.in_time_zone
      end
      
      it "should be an Array and cast it's values given ['1', '2', '3']" do
        search = Order.search
        search.id_equals_any = ["1", "2", "3"]
        search.id_equals_any.should == [1, 2, 3]
      end
      
      it "should type cast association conditions" do
        search = User.search
        search.orders_total_gt = "10"
        search.orders_total_gt.should == 10
      end
      
      it "should type cast deep association conditions" do
        search = Company.search
        search.users_orders_total_gt = "10"
        search.users_orders_total_gt.should == 10
      end
    end
  end
  
  context "taking action" do
    it "should return all when not given any conditions" do
      3.times { User.create }
      User.search.all.length.should == 3
    end
    
    it "should implement the current scope based on an association" do
      User.create
      company = Company.create
      user = company.users.create
      company.users.search.all.should == [user]
    end
    
    it "should implement the current scope based on a named scope" do
      User.named_scope(:four_year_olds, :conditions => {:age => 4})
      (3..5).each { |age| User.create(:age => age) }
      User.four_year_olds.search.all.should == User.find_all_by_age(4)
    end
    
    it "should call named scopes for conditions" do
      User.search(:age_less_than => 5).proxy_options.should == User.age_less_than(5).proxy_options
    end
    
    it "should alias exact column names to use equals" do
      User.search(:username => "joe").proxy_options.should == User.username_equals("joe").proxy_options
    end
    
    it "should recognize conditions with a value of true where the named scope has an arity of 0" do
      User.search(:username_nil => true).proxy_options.should == User.username_nil.proxy_options
    end
    
    it "should ignore conditions with a value of false where the named scope has an arity of 0" do
      User.search(:username_nil => false).proxy_options.should == {}
    end
    
    it "should recognize the order condition" do
      User.search(:order => "ascend_by_username").proxy_options.should == User.ascend_by_username.proxy_options
    end
  end
end