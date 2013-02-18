require 'spec_helper'

describe Searchlogic::Search::SearchProxy::ChainedConditions do 
  before(:each) do 
    User.create(:name=>"James", :age =>20, :username => "jvans1" )
    User.create(:name=>"James Vanneman", :age =>21, :username => "jvans1")
    User.create(:name => "Tren")
    User.create(:name=>"Ben")
  end
  it "sets conditions with attribute writers" do 
      search = User.search
      search.name_contains = "James"
      search.age_lt = 21
      search.username_eq = "jvans1"
      james = search.all 
      james.count.should eq(1)
      name = james.map(&:name)
      name.should eq(["James"])
  end

  it "overrides conditions with attribute writers" do 
    search = User.search(:name_bw => "Ja")
    search.all.map(&:name).should eq(["James", "James Vanneman"])
    search.name_bw = "B"
    ben = search.all
    ben.count.should eq(1)
    ben.map(&:name).should eq(["Ben"])
  end
  
  it "should return nil for empty condition" do 
    search = User.search(:name_ew => "man")
    search.name_bw.should be_nil
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

  xit "Calling All without conditions returns all users" do 
    search = User.search
    search.all.count.should eq(4)
  end
  ##NOTE support this?
  xit "returns users with nil attributes when explicity set" do 
    search = User.search(:username_eq => "James")
    search.username_eq = nil
    search.all.count.should eq(2)
    search.first.username.should eq(["Tren", "Ben"])
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
  end
end