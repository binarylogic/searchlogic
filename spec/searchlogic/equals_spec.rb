require 'spec_helper'

describe Searchlogic::Conditions::Equals do
  before(:each) do 
    @james = User.create(:name=>"James")
    @ben = User.create(:name=> "Ben")
  end

  describe "Equals Query on Single Column" do 
    it "returns the user when column exists"  do 
      users = User.name_equals("James")
      users.count.should eq(1)
      james = users.first
      james.name.should eq("James")
    end

    it "checks against multiple" do 
      users = User.name_equals(["Ben","James"])
      names = users.map { |u| u.name }
      names.count.should eq(2)
      names.should eq(["Ben","James"])
    end
    xit "and raises NoMethodError when column doesn't exist" do 
      User.titties_equals("Big").should_raise NoMethodError
    end 
  end
end