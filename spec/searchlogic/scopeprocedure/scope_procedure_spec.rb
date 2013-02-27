require 'spec_helper'

describe Searchlogic::ActiveRecordExt::ScopeProcedure::ClassMethods do 
  before(:each) do 
    class User
      scope_procedure :awesome, lambda{ name_like("James")}
    end
    User.create(:name=>"James", :age =>20, :username => "jvans1", :email => "jvannem@gmail.com" )
    User.create(:name=>"James Vanneman", :age =>21, :username => "jvans1", :email => "jvannem@gmail.com" )
    User.create(:name => "Tren", :age =>45, :email => "jvannem@gmail.com" )
    User.create(:name=>"Ben", :age =>20, :email => "Ben@gmail.com" )
  end
  after(:each) do 
    User.searchlogic_scopes.clear
    Order.searchlogic_scopes.clear
  end

  it "creates a scopes procedure with custom conditions" do 
    class User;
      scope_procedure(:young, lambda {  age_lt(21).name_not_like("Ben") })
    end
    users = User.young
    users.count.should eq(1)
    users.first.name.should eq("James")
  end

  it "calls scope proc with an arity of 0" do 
    class User; scope_procedure :cool, lambda{ where("name LIKE ?", "%Jam%") }; end
    cool_users = User.cool
    cool_users.count.should eq(2)
    cool_users.map(&:name).should eq(["James", "James Vanneman"])    
  end

  it "calls scope procedure with arity of 1 " do 
    class User; scope_procedure :old, lambda{ |given_age| where("age > ?", given_age) }; end
    old_users = User.old(21)
    old_users.count.should eq(1)
    old_users.first.name.should eq("Tren")
  end

  it "calls scope procedure with arity > 1" do 
    class User; scope_procedure :fun, lambda{ |name, age| where("name like ? AND age = ?", name, age ) };end
    fun_users = User.fun("James", 20)
    fun_users.count.should eq(1)
    fun_users.first.name.should eq("James")
  end

  it "calls scope procedure with class level methods" do 
    class User; def self.old(age); where("age > ?", age); end; end
    User.scope_procedure(:older, lambda{ |age| User.old(age)})
    really_old = User.older(26)
    really_old.count.should eq(1)
    really_old.first.name.should eq("Tren")
  end

 it "should pass array values as multiple arguments with arity -1" do
    class User
      scope_procedure(:multiple_args, lambda { |*args|
      raise "This should not be an array, it should be 1" if args.first.is_a?(Array)
      where("id IN (?)", args)

    })
    end
    last_three = User.multiple_args(2,3,4)
    last_three.count.should eq(3)
    names = last_three.map(&:name)
    names.should eq(["James Vanneman", "Tren", "Ben"])
  end

  it "should pass array as a single value with arity >= 0" do
    class User
      scope_procedure(:multiple_args, lambda { |args|
      raise "This should be an array" if !args.is_a?(Array)
      where("id IN (?)", args)
    })
    end
    last_three = User.multiple_args(2,3,4)
    last_three.count.should eq(3)
    names = last_three.map(&:name)
    names.should eq(["James Vanneman", "Tren", "Ben"])
  end


  it "individual classes keeps track of all scope_procedures created" do 
    User.scope_procedure :second_one, lambda { User.first}
    User.scope_procedure :third_one, lambda {User.last}
    Company.scope_procedure :company_scope_one, :conditions => {:name => "Concierge Live"}
    Company.scope_procedure :company_scope_two, :conditions => {:name => "NECO"}
    user_scopes = User.searchlogic_scopes
    company_scopes = Company.searchlogic_scopes
    user_scopes.count.should eq(3)
    user_scopes.should eq([:awesome, :second_one, :third_one])
    company_scopes.count.should eq(2)
    company_scopes.should eq([:company_scope_one, :company_scope_two])
  end

   
end

