require 'spec_helper'

describe Searchlogic::Conditions::Aliases do 
  before(:each) do 
    @james = User.create(:name=>"James", :age => 26)
    User.create(:name=>"Jon")
    @ben = User.create(:name=>"Ben", :age => 28)
    @tren = User.create(:name=>"Tren", :age =>45)
  end

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
  it "gt and after == greater_than" do 
    gt_users = User.age_gt(28)
    after_users = User.age_after(28)
    gt_users.count.should eq(1)
    after_users.count.should eq(1)
    gt_users.first.name.should eq("Tren")
    after_users.first.name.should eq("Tren")
  end

  it "contains and includes == like" do 
    contains = User.name_contains("en")
    includes = User.name_includes("en")
    contains.count.should eq(2)
    includes.count.should eq(2)
    contains.map(&:name).should eq(["Ben", "Tren"])
    includes.map(&:name).should eq(["Ben", "Tren"])
  end


end