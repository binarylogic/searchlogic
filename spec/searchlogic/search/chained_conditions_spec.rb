require 'spec_helper'

describe Searchlogic::Search::SearchProxy::ChainedConditions do 
  before(:each) do 
    User.create(:name=>"James", :age =>20, :username => "jvans1" )
    User.create(:name=>"James Vanneman", :age =>21, :username => "jvans1")
    User.create(:name => "Tren")
    User.create(:name=>"Ben")
  end

  it "chains scopes" do
    search = User.search(:name_like => "James")
    search.all.count.should eq(2)
    search.age_gt(20)
    search.all.count.should eq(1)
  end 

  it "chains multiple scopes" do 
    search = User.search
    search.all.count.should eq(4)
    search.name_like("James").age_eq(20)
    search.all.count.should eq(1)
    search.all.map(&:name).should eq(["James"])
  end

  it "ignores nil on mass assignment" do 
    search = User.search(:username_eq => nil, :name_like =>"James")
    search.all.count.should eq(2)
    search.all.map(&:name).should eq(["James", "James Vanneman"])
  end
  it "finds nil conditions on explicit assignment" do 
    search = User.search
    search.username = nil 
    search.count.should eq(2)
    search.all.map(&:name).should eq(["Tren", "Ben"])
  end

  xit "finds with blank assignment" do 


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
  it "returns users with one condition set" do 
    search = User.search(:age_lt => 21)
    james = search.all 
    james.count.should eq(1)
    james.map(&:name).should eq(["James"])
  end

  describe "no arguement methods" do 
    it "returns all users with non nil username " do 
      User.all.count.should eq(4)
      search = User.search(:username_not_nil => true)
      search.all.count.should eq(2)
      search.all.map(&:name).should eq(["James", "James Vanneman"])
    end
    it "returns all users with nil username when value set to false" do 
      search = User.search(:username_not_nil => false)
      search.all.count.should eq(2)
      search.all.map(&:name).should eq(["Tren", "Ben"])
    end

    it "retuns all users with nil username" do 
      User.all.count.should eq(4)
      search = User.search(:username_nil => true)
      search.all.count.should eq(2)
      search.all.map(&:name).should eq(["Tren", "Ben"])
    end

    it "returns all users without nil username when value set to false" do 
      search = User.search(:username_nil => false)
      search.all.count.should eq(2)
      search.all.map(&:name).should eq(["James", "James Vanneman"])
    end

    it "returns all users with blank name" do 
      search = User.search(:username_blank => true)
      search.all.count.should eq(2)
      search.all.map(&:name).should eq(["Tren", "Ben"])
    end

    it "returns all users without blank names when value set to false" do 
      search = User.search(:username_blank => false)
      search.all.count.should eq(2)
      search.all.map(&:name).should eq(["James", "James Vanneman"])
    end
    it "returns all users with blank name" do 
      search = User.search(:username_not_blank => true)
      search.all.count.should eq(2)
      search.all.map(&:name).should eq(["James", "James Vanneman"])
    end
    
    it "returns all users without blank names when value set to false" do 
      search = User.search(:username_not_blank => false)
      search.all.count.should eq(2)
      search.all.map(&:name).should eq(["Tren", "Ben"])
    end
  end
end