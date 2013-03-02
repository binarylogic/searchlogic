require 'spec_helper'

describe "Searchlogic::SearchExt::Search::ScopeProcedure" do 
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
    it "can combine scope procedure with other args" do 
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

    it "should create a search proxy" do
      User.search(:username_eq => "joe").should be_kind_of(Searchlogic::Search)
    end

    xit "should create a search proxy using the same class" do
      User.search.klass.should eq(User)
    end

    it "should pass on the current scope to the proxy" do
      company = Company.create
      user = company.users.create
      search = company.users.search
      search.all.should eq(company.users)
    end
  end
end