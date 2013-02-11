require 'spec_helper'

describe Searchlogic::Conditions::Aliases do 
  before(:each) do 
    @james = User.create(:name=>"James", :age => 26)
    User.create(:name=>"Jon")
    @ben = User.create(:name=>"Ben", :age => 28)
  end

  describe "Aliases" do 
    it "eq == equals" do 
      users = User.name_eq("James")
      users.count.should eq(1)
      names = users.map(&:name)
      names.should eq(["James"])
    end

    it "is == equals" do 
      users = User.name_is("James")
      users.count.should eq(1)
      names = users.map(&:name)
      names.should eq(["James"])
    end

    it "lt == less_than" do 
      users = User.age_lt(28)
      users.count.should eq(1)
      names = users.map(&:name)
      names.should eq(["James"])
    end

    it "before == less_than" do 
      users = User.age_before(28)
      users.count.should eq(1)
      names = users.map(&:name)
      names.should eq(["James"])
    end

    it "lte == less_than_or_equal_to" do 
      users = User.age_lte(28)
      users.count.should eq(2)
      names = users.map(&:name)
      names.should eq(["James", "Ben"])
    end
  end


end