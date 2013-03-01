require 'spec_helper'

describe Searchlogic::SearchExt::Delegate do 
  before(:each) do 
    @james = User.create(:name=>"James", :age =>20, :username => "jvans1" )
    User.create(:name=>"James Vanneman", :age =>21, :username => "jvans1")
    @tren = User.create(:name => "Tren", :username =>"jvans")
    User.create(:name=>"Ben", :username =>"jvans1")
  end

  context "#delegate" do
    it "delegates to AR relation" do 
      search = User.searchlogic(:username_is => "jvans1")
      search.count.should eq(3)
    end

    it "should delegate the find_* method of active record" do 
      User.find_by_name("James").should eq(@james)
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

  context "#sanitized_conditions" do 
    it "should not ignore blank values in arrays" do
      u1 = User.create(:name => "")
      search = User.search("name_equals_any" => [""])
      search.sanitized_conditions.should eq({:name_equals_any => ""})
      search.conditions = {"name_equals_any" => ["", "Tren"]}
      search.sanitized_conditions.should eq({:name_equals_any => ["", "Tren"]})
      search.all.should eq([@tren, u1])      
    end

    it "should not remove empty strings" do 
      search = User.search
      search = User.search
      search.name_eq = ""
      search.conditions.should eq({:name_eq => ""})
      search.sanitized_conditions.should eq({:name_eq => ""})
    end

    it "should not remove  empty arrays" do
      search = User.search(:name_eq => [""])
      search.sanitized_conditions[:name_eq].should eq("")
    end

    it "should remove scope procedures with a false value" do 
      User.scope :old, lambda {|age| User.age_gt(40)}
      search = User.search(:old => false, :name_equals => "James")
      search.conditions.should eq({:old => false, :name_equals => "James"})
      search.sanitized_conditions.should eq({:name_equals => "James"})
    end
  end

  context "#empty" do 
    it "should respond to empty" do 
      search = Order.search
      search.empty?.should be_true
    end
  end
end