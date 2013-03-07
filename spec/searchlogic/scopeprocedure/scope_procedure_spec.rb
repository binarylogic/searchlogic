require 'spec_helper'

describe Searchlogic::ActiveRecordExt::ScopeProcedure::ClassMethods do 
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
    
    after(:each) do 
      User.named_scopes.clear
      Order.named_scopes.clear
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

    xit "should pass array values as multiple arguments with arity -1" do
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
      User.scope :second_one, lambda { User.first}
      User.scope :third_one, lambda {User.last}
      Company.scope :company_scope_one, lambda{where(Company.name_eq("ConciergeLIve"))}
      Company.scope :company_scope_two,  lambda{where(Company.name_eq("NEco"))}
      user_scopes = User.named_scopes 
      company_scopes = Company.named_scopes 
      user_scopes.count.should eq(3)
      user_scopes.keys.should eq([:awesome, :second_one, :third_one])
      company_scopes.count.should eq(2)
      company_scopes.keys.should eq([:company_scope_one, :company_scope_two])
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
      @@proc = lambda{ User.created_at_after("2012/2/3")}
      class User 
        scope :fun, @@proc 
        alias_scope :fun, :most_fun
      end
      User.named_scopes.keys.should include(:most_fun)
      User.named_scopes[:most_fun].should eq({:type => :boolean, :scope => @@proc})
    end


  end
end

