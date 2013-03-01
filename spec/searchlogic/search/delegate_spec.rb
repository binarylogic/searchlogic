require 'spec_helper'

describe Searchlogic::SearchExt::Delegate do 
  before(:each) do 
    @james = User.create(:name=>"James", :age =>20, :username => "jvans1" )
    User.create(:name=>"James Vanneman", :age =>21, :username => "jvans1")
    User.create(:name => "Tren", :username =>"jvans")
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
    it "should ignore blank values in arrays" do
      User.create(:name => "")
      search = User.search("name_equals_any" => [""])
      search.sanitized_conditions.should be_empty
      search.conditions = {"name_equals_any" => ["", "Tren"]}
      search.sanitized_conditions.should eq({:name_equals_any => ["Tren"]})
      search.all.should eq([User.find_by_name("Tren")])      
    end

    it "should convert nil values to queriable methods" do 
      search = User.search
      search.name = nil
      search.conditions.should eq({:name => nil})
      search.sanitized_conditions.should eq({:name_null => true})
    end

    it "make column names without predicate into equality" do 
      search = User.search(:name => "James")
      search.conditions.should eq({:name=> "James"})
      search.sanitized_conditions.should eq({:name_equals => "James"})
    end

    it "should remove empty strings" do 
      search = User.search
      search = User.search
      search.name_eq = ""
      search.conditions.should eq({:name_eq => ""})
      search.sanitized_conditions.should be_blank
    end

    it "should remove  empty arrays" do
      search = User.search(:name => [""])
      search.sanitized_conditions.should be_blank
    end

    it "should remove scope procedures with a false value" do 
      User.scope_procedure :old, lambda {|age| User.age_gt(40)}
      search = User.search(:old => false, :name => "James")
      search.conditions.should eq({:old => false, :name => "James"})
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