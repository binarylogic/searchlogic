require 'spec_helper'

describe "Searchlogic::Search::SearchProxy::All" do 
  before(:each) do 
    User.create(:name=>"James", :age =>20, :username => "jvans1" )
    User.create(:name=>"James Vanneman", :age =>21, :username => "jvans1")
    User.create(:name => "Tren")
    User.create(:name=>"Ben")
  end


  it "doesn't remove conditions from object" do 
    search = User.search
    search.name_contains = "James"
    search.age_lt = 21
    search.username_eq = "jvans1"
    cond_hash1 = search.conditions
    james = search.all 
    cond_hash2 = search.conditions
    cond_hash1.should eq(cond_hash2)
  end

  it "Calling All without conditions returns all users" do 
    search = User.search
    search.all.count.should eq(4)
  end

  it "calling All when conditions are nil returns all users" do 
    search = User.search(:name_eq => "James")
    search.name_eq = nil
    search.all.count.should eq(4)
  end
end