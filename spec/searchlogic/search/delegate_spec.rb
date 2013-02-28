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

  context "#sanitize_conditions" do 
    it "should ignore blank values in arrays" do
      User.create(:name => "")
      search = User.search(:conditions => {"name_equals_any" => [""]})
      search.name_equals_any.should be_nil
      search.conditions = {"name_equals_any" => ["", "Tren"]}
      search.conditions.should eq({:name_equals_any => ["Tren"]})
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