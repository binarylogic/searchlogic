require 'spec_helper'

describe Searchlogic::Search::ReaderWriter do 
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

  it "overrides conditions with attribute writers" do 
    search = User.searchlogic(:name_bw => "Ja")
    search.all.map(&:name).should eq(["James", "James Vanneman"])
    search.name_bw = "B"
    ben = search.all
    ben.count.should eq(1)
    ben.map(&:name).should eq(["Ben"])
  end
  it "should return nil for empty condition" do 
    search = User.searchlogic(:name_ew => "man")
    search.name_bw.should be_nil
  end
end