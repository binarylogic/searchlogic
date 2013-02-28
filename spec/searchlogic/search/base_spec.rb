  require 'spec_helper'

  describe Searchlogic::SearchExt::Base do 
  before(:each) do 
    @James = User.create(:name=>"James", :age =>20, :username => "jvans1", :email => "jvannem@gmail.com" )
    @JamesV = User.create(:name=>"James Vanneman", :age =>21, :username => "jvans1")
    @Tren = User.create(:name => "Tren", :age =>11, :username => "Tren")
    @Ben = User.create(:name=>"Ben", :age => 12, :username => "")
  end

  context "#initialize" do
    it "should require a class" do
      lambda { Searchlogic::Search.new }.should raise_error(ArgumentError)
    end

    it "should set the conditions" do
      search = User.search(:username => "bjohnson")
      search.conditions.should == {:username => "bjohnson"}
    end
  end


  context "#sanitize_conditions" do 
    it "ignores nil on mass assignment" do 
      search = User.searchlogic(:username_eq => nil, :name_like =>"James")
      search.count.should eq(2)
      search.map(&:name).should eq(["James", "James Vanneman"])
    end    

    it "ignores unauthorized scopes on mass assignment" do 
      search = User.search(:username_eq => nil, :age_gt => 26, :destroy_all => true, :awesome => "AwesoemS")
      search.conditions.should eq({:age_gt=> 26 })
    end 
    
    it "should ignore blank values but still return on conditions" do
      User.create(:username => "")
      search = User.search
      search.conditions = {"username" => ""} 
      search.username.should eq("")
    end

    it "should not merge conflicting conditions into one value" do
      # This class should JUST be a proxy. It should not do anything more than that.
      # A user would be allowed to call both named scopes if they wanted.
      search = User.search
      search.username_greater_than = "jvans1"
      search.username_gt = "jvans1"
      search.username_greater_than.should == "jvans1"
      search.username_gt.should == "jvans1"
    end   

    it "should ignore blank values in arrays" do
      User.create(:username => "")
      search = User.search
      search.conditions = {"username_equals_any" => [""]}
      search.username_equals_any.should eq([""])
      search.all.should eq(User.all)

      search.conditions = {"username_equals_any" => ["", "Tren"]}
      search.all.should eq([User.find_by_name("Tren")])      
    end
    it "allows string keys" do
      search = User.search("name_eq" => "James")
      search.map(&:name).should eq(["James"])
    end  
  
  end

  context "#clone" do
    it "should clone properly" do
      company = Company.create
      user1 = company.users.create(:age => 5)
      user2 = company.users.create(:age => 25)
      search1 = company.users.search(:age_gt => 10)
      search2 = search1.clone
      search2.age_gt = 1
      
      search2.all.should eq(User.all)
      search1.all.should eq([@James, @JamesV, @Tren, @Ben, user2])
    end

    it "should clone properly without scope" do
      user1 = User.create(:age => 5)
      user2 = User.create(:age => 25)
      search1 = User.search
      search2 = search1.clone
      search2.age_gt = 12

      search2.all.should eq([@James, @JamesV, user2])
      search1.all.should eq(User.all)
    end
  end


end