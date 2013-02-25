require 'spec_helper'

describe Searchlogic::SearchExt::ReaderWriter do 
  before(:each) do 
    User.create(:name=>"James", :age =>20, :username => "jvans1" )
    User.create(:name=>"James Vanneman", :age =>21, :username => "jvans1")
    User.create(:name => "Tren")
    User.create(:name=>"Ben")
  end

  it "has readers for conditions" do
    search = User.searchlogic(:name_ew => "man")
    search.name_ew.should eq("man")
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

  context "#removeemptystring" do 
    it "should ignore blank values but still return on conditions" do
      search = User.search
      search.conditions = {"username" => ""} 
      search.all.should eq(User.all)     
      search.conditions.should eq({"username" => ""})
    end
    it "should ignore blank values in arrays" do
      search = User.search
      search.conditions = {"username_equals_any" => [""]}
      search.username_equals_any.should eq([""])
      search.all.should eq(User.all)
      search.conditions = {"id_equals_any" => ["", "1"]}
      search.all.should eq([User.find(1)])      
    end
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


  context "assigning nils" do
    it "finds on explicit assignment" do 
      search = User.searchlogic
      search.username = nil 
      search.count.should eq(2)
      search.map(&:name).should eq(["Tren", "Ben"])
    end

    it "finds with explicit assignment and other args" do 
      search = User.search(:name_contains => "James")
      search.email = nil 
      search.conditions.should eq({:name_contains => "James", :email => nil})
      search.count.should eq(2)
      search.map(&:name).should eq(["James", "James Vanneman"])
    end
  end
end