require 'spec_helper'

describe Searchlogic::ActiveRecordExt::NamedScopes::ClassMethods do 
  context "scope_procedure" do
    before(:each) do 
      class User
        scope :awesome, lambda{ name_like("James")}
      end
      @james = User.create(:name=>"James", :age =>20, :username => "jvans1", :email => "jvannem@gmail.com" )
      @jamesv = User.create(:name=>"James Vanneman", :age =>21, :username => "jvans1", :email => "jvannem@gmail.com" )
      @tren = User.create(:name => "Tren", :age =>45, :email => "jvannem@gmail.com" )
      @ben =  User.create(:name=>"Ben", :age =>20, :email => "Ben@gmail.com", :username => "bjohnson" )
    end

    it "should allow named scopes to be called multiple times and reflect the value passed" do
      @co1 = Company.create(:users => [@james, @jamesv, @ben, @tren])
      @co2 = Company.create(:users => [@james])
      Company.users_username_like("bjohnson").should eq([@co1])
      Company.users_username_like("jvans1").should eq([@co2, @co1])
    end


    it "creates a scopes procedure with custom conditions" do 
      class User;
        scope(:young, lambda {  age_lt(21).name_not_like("Ben") })
      end
      users = User.young
      users.count.should eq(1)
      users.first.name.should eq("James")
    end

    it "works with deep OR conditions " do
      class User
        scope(:winning, lambda{ age_greater_than_or_equal_to_or_id_less_than_or_equal_to_or_name_like("10")})
      end
      User.winning.should eq(User.all)
    end

    it "works with or conditiosn in associations" do 
      class User; scope :name_lt, lambda{name_like("Ja")}; scope :seniority_gt, lambda{|age| age_gt(age)};end
      search = User.search(:created_at_after => "2012/3/2", :orders_line_items_price_or_id_gte => 1, :name_lt => true, :audits_name_or_carts_id_eq => "5", :order => :descend_by_id)
      search.all.should be_empty
    end
    it "calls scope proc with an arity of 0" do 
      class User; scope :cool, lambda{ where("name LIKE ?", "%Jam%") }; end
      cool_users = User.cool
      cool_users.count.should eq(2)
      cool_users.map(&:name).should eq(["James", "James Vanneman"])    
    end

    it "calls scope procedure with arity of 1 " do 
      class User; scope :old, lambda{ |given_age| where("age > ?", given_age) }; end
      old_users = User.old(21)
      old_users.count.should eq(1)
      old_users.first.name.should eq("Tren")
    end

    it "calls scope procedure with arity > 1" do 
      class User; scope :fun, lambda{ |name, age| where("name like ? AND age = ?", name, age ) };end
      fun_users = User.fun("James", 20)
      fun_users.count.should eq(1)
      fun_users.first.name.should eq("James")
    end

    it "calls scope procedure with class level methods" do 
      class User; def self.old(age); where("age > ?", age); end; end
      User.scope(:older, lambda{ |age| User.old(age)})
      really_old = User.older(26)
      really_old.count.should eq(1)
      really_old.first.name.should eq("Tren")
    end

    it "should pass array values as multiple arguments with arity -1" do
      class User
        scope(:not_array_args, lambda { |args| #*
        raise "This should not be an array, it should be 1" if args.first.is_a?(Array)
        where("id IN (?)", args)
        })
      end
      last_three = User.not_array_args([2,3,4])
      last_three.count.should eq(3)
      names = last_three.map(&:name)
      names.should eq(["James Vanneman", "Tren", "Ben"])
    end

    it "should pass array as a single value with arity >= 0" do
      class User
        scope(:multiple_args, lambda { |*args|
        raise "This should be an array" if !args.is_a?(Array)
        where("id IN (?)", args)
      })
      end
      last_three = User.multiple_args(2,3,4)
      last_three.count.should eq(3)
      names = last_three.map(&:name)
      names.should eq(["James Vanneman", "Tren", "Ben"])
    end

    it "individual classes keeps track of all scopes created" do 
      existing_user = User.named_scopes.keys
      existing_co = Company.named_scopes.keys
      class User; scope :first_one, lambda { id_eq(1)};end
      User.scope :second_one, lambda {User.last}
      Company.scope :company_scope_one, lambda{where(Company.name_eq("ConciergeLIve"))}
      Company.scope :company_scope_two,  lambda{where(Company.name_eq("NEco"))}
      user_scopes = User.named_scopes
      company_scopes = Company.named_scopes
      (user_scopes.count - existing_user.count).should eq(2)
      (user_scopes.keys - existing_user).should eq([:first_one, :second_one])
      (company_scopes.count - existing_co.count).should eq(2)
      (company_scopes.keys - existing_co).should eq([:company_scope_one, :company_scope_two])
    end
  end

  context "alias scope" do 
    it "allows you to alias a scope" do 
      u1 = User.create(:age => 41)
      class User 
        scope :old, lambda{ age_after(40)}
        alias_scope :old, :older
      end
      User.older.should eq([u1])
    end
    it "works on class methods" do 
      class User
        alias_scope :fun_name, :my_name
        def self.fun_name
          name_ew("mes")
        end
      end
      u1 = User.create(:name => "James")
      User.create(:name =>"messy")
      User.my_name.should eq([u1])
    end

    it "keeps track of type on class method" do 
      class User
        alias_scope :fun_name, :my_name
        def self.fun_name
          name_ew("mes")
        end
      end      
      User.named_scopes[:my_name].should eq({:type => :unspecified})
    end

    it "allows you to specify a type" do 
      class User
        alias_scope :fun_name, :my_name, :type => :boolean   
        def self.fun_name
          name_ew("mes")
        end
      end
      User.named_scopes[:my_name].should eq({:type => :boolean})
    end

    it "allows you to alias scope with arity > 0" do 
      u2 = User.create(:name => "James", :created_at => Date.new(2012,1,31))
      u1 = User.create(:name => "James")
      class User 
        scope :talented, lambda{ |date, name| created_at_after(date).name_like(name)}
        alias_scope :talented, :most_talented
      end
      User.most_talented("2012/2/3", "James").should eq(User.talented("2012/2/3", "James"))
    end

    it "assigns named scope values for alias_scope's" do
      $proc = lambda{ User.created_at_after("2012/2/3")}
      class User 
        scope :fun, $proc 
        alias_scope :fun, :most_fun
      end
      User.named_scopes.keys.should include(:most_fun)
      User.named_scopes[:most_fun].should eq({:type => :boolean, :scope => $proc})
    end

    it "works with a search object" do 
      class User
        alias_scope :fun_name, :my_name, :type => :boolean   
        def self.fun_name
          name_ew("mes")
        end
      end
      search = User.search(:my_name => "true")
      u1 =  User.create
      u2 = User.create(:name => "James")
      search.all.should eq([u2])
      User.search(:my_name => "false").all.should eq([u1, u2])
    end

    it "works with search object and arity > 0 " do 
      u2 = User.create(:name => "James", :created_at => Date.new(2014,1,31))
      u1 = User.create(:name => "James")
      class User 
        def self.talented(date, name)
          created_at_after(date).name_like(name)
        end
        alias_scope :talented, :most_talented

      end
      User.search(:most_talented => [Date.new(2014,1,30), "am"]).all.should eq([u2])
    end

    it "works on end of method calls" do 
      u2 = User.create(:name => "James", :created_at => Date.new(2014,1,31))
      u1 = User.create(:name => "James", :created_at => Date.new(2012,1,31))
      u3 = User.create(:username => "James")
      class User 
        def self.talented(name)
          created_at_after(Date.today).name_like(name)
        end
        alias_scope :talented, :most_talented
      end
      User.username_is_or_most_talented("James").should eq([u2,u3])
    end
  end

  describe "In Search object" do 
    before(:each) do
      class User
        scope(:young, lambda { age_lt(21)})
        scope :awesome, lambda { name_like("James") }
      end
      james = User.create(:name=>"James", :age =>20, :username => "jvans1", :email => "jvannem@gmail.com" )
      @jamesv = User.create(:name=>"James Vanneman", :age =>21, :username => "jvans1")
      User.create(:name => "Tren", :age =>21)
      User.create(:name=>"Ben", :age =>26)
      Company.create(:users => [james])
    end
    context "Mass Assignment" do
      it "can be called with scope procedure" do 
        search = User.search(:awesome => true, :young => true)
        search.count.should eq(1)
        search.map(&:name).should eq(["James"])
      end

      it "doesn't call scope procecure when left out" do 
        search = User.search
        search.count.should eq(4)
        search.map(&:name).should eq(["James", "James Vanneman", "Tren", "Ben"])
      end

      it "can come scope procedure with other args" do 
        search = User.search( :age_gte => "21", :awesome => true )
        search.count.should eq(1)
        search.first.should eq(@jamesv)
      end

      it "doesn't call scope procedure when assigned false" do 
        search = User.search(:awesome => true, :young => false)
        search.count.should eq(2)
        search.map(&:name).should eq(["James", "James Vanneman"])    
      end
    end

    context "scopes" do
      it "should use custom scopes before normalizing" do
        class User; scope(:cust_username, lambda{ |value| username_eq(value.reverse)} ); end
        search1 = User.search(:cust_username => "jvans1")
        search2 = User.search(:cust_username => "1snavj")    
        search1.count.should eq(0)
        search2.count.should eq(2)
      end

      it "should allow setting pre-existing association conditions" do
        class User
          User.scope :uname, lambda { |value| where("users.username = ?", value) }
        end
        search = Company.search
        search.users_uname = "jvans1"
        search.users_uname.should eq("jvans1")
      end

      it "should allow setting custom conditions individually with an arity of 0" do
        class User
          scope(:twenty_years_old, lambda{ age_eq(20)})
        end
        search = User.search
        search.twenty_years_old = true
        search.twenty_years_old.should eq(true)
        search.count.should eq(1)
      end

      it "should delegate to scope procedure with arity > 1" do
        class User
          scope :paged, lambda {|start, limit | limit(limit).offset(start) }
        end
        User.create(:username => "bjohnson")
        search = User.search(:username_equals => "bjohnson")
        search.paged(0, 1).count.should eq(1)
        search.paged(0, 0).count.should eq(0)
      end 

      it "works with 3 args" do 
        class User; scope :fun, lambda{|age, name, email| age_eq(age).name_like(name).email_ends_with_or_email_begins_with(email)};end
        User.create(:age => 26, :name =>"Jam", :email => "email")
        User.create(:age => 26, :name =>"James", :email => "ilmail")
        User.create(:age => 26, :name =>"James", :email => "notmail")
        User.create(:age => 26, :name =>"Jess", :email => "email")
        users = User.search(:fun =>[26,"Jam", "il"])
        users.count.should eq(3)
      end

      xit "should create a search proxy" do
        ##This works but delegates to AR::Rel so returns false
        User.search(:username_eq => "joe").should be_kind_of(Searchlogic::Search)
      end

      it "should create a search proxy using the same class" do
        User.search.klass.klass.should eq(User)
      end

      it "should create a search proxy with an active record relation" do
        User.search.klass.class.should eq(ActiveRecord::Relation)
      end

      it "should pass on the current scope to the proxy" do
        company = Company.create
        user = company.users.create
        search = company.users.search
        search.all.should eq(company.users)
      end

      it "works with or conditions" do 
        u1 = User.create(:orders => [Order.create(:total => 6)], :name => "James", :age => 26)
        search = User.search(:name_equals => "James", :age_greater_than_or_equal_to => 20, :id_eq_or_orders_total_greater_than_or_equal_to => 5)
        search.all.should eq([u1])
      end

      it "works with arity > 2" do 
        class User
          scope(:winning, lambda{ |age, email, name| age_eq(age).email_like(email).name_ew(name)})
        end
        search = User.search(:id_gte => 1, :winning => [20, "vann", "es"])
        search.count.should eq(1)
        search.map(&:name).should eq(["James"])
      end

      it "works with an arity = 0 and string assignment" do 
        class User
          scope(:winning, lambda{ where("age > ? ", 21)})
        end      
        search = User.search
        search.winning = "true"
        search.count.should eq(1)
        search.map(&:name).should eq(["Ben"])
      end

      it "returns class.all if no scope conditoins" do 
        search = User.search 
        search.all.should eq(User.all)

      end 


      it "works with strings for integer values" do 
        search = User.search
        search.id_eq = "2"
        search.count.should eq(1)
        search.all.should eq([@jamesv])
      end

      it "should pass array values as multiple arguments with arity -1 in search object" do
        class User
          scope(:multiple_args, lambda { |*args|
          where("id IN (?)", args)
        })
        end
        search = User.search
        search.multiple_args = [2,3,4]
        search.count.should eq(3)
        names = search.map(&:name)
        names.should eq(["James Vanneman", "Tren", "Ben"])
      end

      it "should pass array values an array with arity = 1" do
        class User
          scope(:multiple_args, lambda { |args|
              raise "This should be an array" unless args.is_a?(Array)
            where("id IN (?)", args)
          })
        end
        search = User.search
        search.multiple_args = [2,3,4]
        search.count.should eq(3)
        names = search.map(&:name)
        names.should eq(["James Vanneman", "Tren", "Ben"])
      end

      it "should pass a date object" do 
        class Order
          scope(:expired, lambda { |end_date| where("created_at < ?", end_date)})
          named_scopes[:expired][:type] = :time
        end

        Order.create
        search = Order.search
        search.expired = "2020, 1, 2"
        search.conditions[:expired].should be_kind_of(Time)
      end
    end
    context "type cast" do 
      it "typecasts on write" do 
        class User; scope :can_drink, lambda{ age_gt(21)};end
        search = User.search(:can_drink => "false")
        search.conditions[:can_drink].should be_false
      end
    end  
  end
  context " OR conditions" do 
    it "works with or conditions with conflicting alias names" do 
      class User; scope :name_lt, lambda{name_like("Ja")}; scope :seniority_gt, lambda{|age| age_gt(age)};end
      user1 = User.create(:age => 41)
      user2 = User.create(:name => "James")
      User.name_lt_or_seniority_gt(40).should eq([user1, user2])
      User.name_lt_or_seniority_gt(40).name_begins_with_or_id_greater_than_or_equal_to(10)
    end

  end
end

