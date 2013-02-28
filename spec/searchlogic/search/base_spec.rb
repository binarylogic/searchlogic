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


  context "#initial_sanitize" do 
    it "ignores nil on mass assignment" do 
      search = User.searchlogic(:username_eq => nil, :name_like =>"James")
      search.count.should eq(2)
      search.map(&:name).should eq(["James", "James Vanneman"])
    end    

    it "ignores unauthorized scopes on mass assignment" do 
      search = User.search(:age_gt => 26, :unauthorized => "not ok")
      search.conditions.should eq({:age_gt=> 26 })
    end 

    it "ignores nils on mass assignmetn" do 
      search = User.search(:name_eq => nil)
      search.conditions.should be_empty
    end

    it "ignores destructive methods" do 
      search = User.search(:destroy => true)
      search.conditions.should be_empty
    end

    it "should ignore blank values" do
      User.create(:username => "")
      search = User.search(:conditions => {"username" => ""} )
      search.username.should be_nil
      search = User.search(:name => [])
      search.name.should be_nil
    end

    it "should ignore blank values in arrays" do
      User.create(:username => "")
      search = User.search("username_equals_any" => [""])
      search.username_equals_any.should be_nil
      search.all.should eq(User.all)
      search.conditions = {"username_equals_any" => ["", "Tren"]}
      search.conditions.should eq({:username_equals_any => ["", "Tren"]})
    end

    it "converts string keys to symbols" do
      search = User.search("name_eq" => "James")
      search.conditions.should eq({:name_eq => "James"})
      search.name_eq.should eq("James")
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