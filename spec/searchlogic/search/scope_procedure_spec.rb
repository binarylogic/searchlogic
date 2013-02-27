require 'spec_helper'

describe "Searchlogic::SearchExt::ScopeProcedure" do 
  before(:each) do
    User.scope_procedure(:young, { :age_lt => 21 })
    User.scope_procedure :awesome,  {:name_like => "James"}
    User.create(:name=>"James", :age =>20, :username => "jvans1", :email => "jvannem@gmail.com" )
    User.create(:name=>"James Vanneman", :age =>21, :username => "jvans1")
    User.create(:name => "Tren", :age =>21)
    User.create(:name=>"Ben", :age =>26)
  end
  xit "creates a scopes procedure with a second argument as a Searchlogic conditions hash" do 
    users = User.young
    users.count.should eq(1)
    users.first.name.should eq("James")
  end
  xit "can have multiple arguments" do 
    User.scope_procedure(:unique, { :age_is => 21, :name_like => "James"})
    users = User.unique 
    users.count.should eq(1)
    users.map(&:name).should eq(["James Vanneman"])
  end

  xit "can be called with scope procedure in mass assignment" do 
    search = User.search(:awesome => true, :young => true)
    search.count.should eq(1)
    search.map(&:name).should eq(["James"])
  end

  xit "doesn't call scope procecure when left out" do 
    search = User.search
    search.count.should eq(4)
    search.map(&:name).should eq(["James", "James Vanneman", "Tren", "Ben"])
  end
  
  xit "doesn't call scope procedure when assigned false" do 
    search = User.search(:awesome => true, :young => false)
    search.count.should eq(2)
    search.map(&:name).should eq(["James", "James Vanneman"])    
  end

  it "calls scope procedure with arity of 1 " do 
    User.scope_procedure :old, lambda{ |given_age| User.where("age > ?", given_age) }
    old_users = User.old(21)
    old_users.count.should eq(1)
  end

  xit "should use custom scopes before normalizing" do
    User.scope_procedure(:cust_username){ |value| {:username => value.reverse}}
    search1 = User.search(:cust_username => "jvans1")
    search2 = User.search(:cust_username => "1snavj")    
    search1.count.should eq(0)
    search2.count.should eq(2)
  end

  xit "should allow setting pre-existing association conditions" do
    User.named_scope :uname, lambda { |value| {:conditions => ["users.username = ?", value]} }
    search = Company.search
    search.users_uname = "bjohnson"
    search.users_uname.should == "bjohnson"
  end
  it "should allow setting custom conditions individually with an arity of 0" do
    User.named_scope(:four_year_olds, :conditions => {:age => 4})
    search = User.search
    search.four_year_olds = true
    search.four_year_olds.should == true
  end

  xit "should allow setting pre-existing association alias conditions" do
    User.alias_scope :username_has, lambda { |value| User.username_like(value) }
    search = Company.search
    search.users_username_has = "bjohnson"
    search.users_username_has.should == "bjohnson"
  end
    xit "should delegate to named scopes with arity > 1" do
      User.named_scope :paged, lambda {|start, limit| { :limit => limit, :offset => start }}
      User.create(:username => "bjohnson")
      search = User.search(:username => "bjohnson")
      search.paged(0, 1).count.should == 1
      search.paged(0, 0).count.should == 0
    end  

end