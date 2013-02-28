require 'spec_helper'

describe Searchlogic::SearchExt::Delegate do 
  before(:each) do 
    User.create(:name=>"James", :age =>20, :username => "jvans1" )
    User.create(:name=>"James Vanneman", :age =>21, :username => "jvans1")
    User.create(:name => "Tren", :username =>"jvans")
    User.create(:name=>"Ben", :username =>"jvans1")
  end

  context "#delegate" do
    it "delegates to AR relation" do 
      search = User.searchlogic(:username_is => "jvans1")
      search.count.should eq(3)
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
  end

  context "#sanitize" do 
    it "should ignore blank values in arrays" do
      User.create(:username => "")
      search = User.search(:conditions => {"username_equals_any" => [""]})
      search.username_equals_any.should be_nil
      search.conditions = {"username_equals_any" => ["", "Tren"]}
      search.conditions.should eq({:username_equals_any => ["Tren"]})
      search.all.should eq([User.find_by_name("Tren")])      
    end

  end
  context "#implicit equals" do 
    it "allows ommission of 'eq' on attributes" do 
      search = User.searchlogic(:name => "James")
      james = search.all
      james.count.should eq(1)
      james.first.name.should eq("James")
    end
  end
  context "#empty" do 
    it "should respond to empty" do 
      search = Order.search
      search.empty?.should be_true
    end
  end
end