require 'spec_helper'

describe Searchlogic::ActiveRecordExt::Scopes::Conditions::Equals do
  before(:each) do 
    @james = User.create(:name=>"James", :age=>28)
    @ben = User.create(:name=> "Ben", :age=>30)
    @tren = User.create(:name=> "Tren", :age=>21)
    @john = User.create(:name=> "John", :age=>20)
    @sarah = User.create(:name=> "Sarah", :age=>26)
  end

  describe "Equals Query on Single Column" do 
    it "returns the user when column exists"  do 
      users = User.name_equals("James")
      users.count.should eq(1)
      james = users.first
      james.name.should eq("James")
    end

    it "checks against multiple values in array" do 
      users = User.name_equals(["Ben","James"])
      names = users.map { |u| u.name }
      names.count.should eq(2)
      names.should eq(["James", "Ben"])
    end

    xit "checks against multiple values in cdl" do
      users = User.age_equals(21, 20, 26)
      users.should eq(@tren, @john, @sarah)
    end

    it "can be chained with other scopes" do 
      james = User.create(:name=>"James", :age=>26)
      users = User.name_equals("James").age_equals(28)
      users.count.should eq(1)
      users.first.name.should eq("James")
      users.first.age.should eq(28)
    end
  end
end