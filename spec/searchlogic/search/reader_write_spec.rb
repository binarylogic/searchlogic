require 'spec_helper'

describe Searchlogic::SearchExt::ReaderWriter do 
  before(:each) do 
    o1 = Order.create(:total => 15)
    o2 = Order.create(:total => 10)
    o3 = Order.create(:total => 10)
    o4 = Order.create(:total =>9)
    o5 = Order.create(:total => 10)    
    o6 = Order.create(:total => 12)    

    @james = User.create(:orders => [o1,o3])
    User.create(:age =>21, :username => "jvans1", :orders => [o6])
    @tren  = User.create(:orders => [o5,o2])
    @ben = User.create(:orders => [o4])

    User.create(:name=>"James", :age =>20, :username => "jvans1" )
    User.create(:name=>"James Vanneman", :age =>21, :username => "jvans1")
    User.create(:name => "Tren", :username => "Tren")
    User.create(:name=>"Ben", :email => "ben@gmail.com")                
  end


  context "accessors" do 
    it "has readers for conditions" do
      search = User.searchlogic(:name_ew => "man")
      search.name_ew.should eq("man")
    end

    it "lets you write methods on associatiated columns" do 
      search = User.search 
      search.orders_total_equals = 10
      search.all.should eq([@tren, @james])
    end

    it "should not use the ruby implementation of the id method" do
      search = User.search
      search.id.should be_nil
    end

    it "sets conditions with attribute writers" do 
        search = User.searchlogic
        search.name_contains = "James"
        search.age_lt = 21
        search.username_eq = "jvans1"
        james = search.all 
        james.count.should eq(1)
        name = james.map(&:name)
        name.should eq(["James"])
    end

    it "should allow setting association conditions" do
      search = User.search
      search.orders_total_gt = 10
      search.orders_total_gt.should == 10
    end  

    it "should allow setting pre-existing association conditions" do
      class User
        scope_procedure(:uname, lambda{ |value| User.where("users.username = ?", value)})
      end
      search = Company.search
      search.users_uname = "bjohnson"
      search.users_uname.should eq("bjohnson")
    end

    it "overrides conditions with attribute writers" do 
      search = User.searchlogic(:name_bw => "Ja")
      search.map(&:name).should eq(["James", "James Vanneman"])
      search.name_bw = "B"
      ben = search.all
      ben.count.should eq(1)
      ben.map(&:name).should eq(["Ben"])
    end

    it "should return nil for empty condition" do 
      search = User.searchlogic(:name_ew => "man")
      search.name_bw.should be_nil
    end

    it "should not merge conflicting conditions into one value" do
      # This class should JUST be a proxy. It should not do anything more than that.
      # A user would be allowed to call both named scopes if they wanted.
      search = User.search
      search.username_greater_than = "bjohnson1"
      search.username_gt = "bjohnson2"
      search.username_greater_than.should eq("bjohnson1")
      search.username_gt.should eq("bjohnson2")
    end

    it "should allow setting custom conditions with an arity of 0" do
      User.scope_procedure(:four_year_olds, lambda { User.age_equals(4)})
      search = User.search
      search.four_year_olds = true
      search.four_year_olds.should eq(true)
    end

    it "should allow setting custom conditions individually with an arity of 1" do
      User.scope_procedure(:username_should_be, lambda { |u| {:conditions => {:username => u}} })
      search = User.search
      search.username_should_be = "bjohnson"
      search.username_should_be.should eq("bjohnson")
    end 


  end
  context "#reader_writer_sanitize" do
    it "should allow you to assign blank values" do
      #Will be ignored when search is performed
      User.create(:username => "")
      search = User.search
      search.username_eq = ""
      search.username_eq.should eq("")
    end
    it "should allow blank values" do 
      search = User.search
      search.username_equals_any = ""
      search.username_equals_any.should eq("")
      search.name_eq(["", "Tren"])
      search.name_eq.should eq(["","Tren"])
      search.conditions.should eq({ :name_eq => ["",  "Tren"], :username_equals_any => ""})
    end    

    it "should not remove nils" do 
      search = User.searchlogic
      search.username_eq = nil 
      search.count.should eq(4)
      search.map(&:name).should eq([ nil, nil, nil, "Ben"])
    end

    it "finds with explicit assignment and other args" do 
      search = User.search(:name_contains => "James")
      search.email_eq = nil 
      search.conditions.should eq({:name_contains => "James", :email_eq => nil})
      search.count.should eq(2)
      search.map(&:name).should eq(["James", "James Vanneman"])
    end
  end
end