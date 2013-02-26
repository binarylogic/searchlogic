require 'spec_helper'

describe Searchlogic::ActiveRecordExt::Scopes::Conditions::Equals do
  before(:each) do 
    User.create(:name=>"James", :age=>28)
    User.create(:name=> "Ben")
  end

  describe "Equals Query on Single Column" do 
    it "returns the user when column exists"  do 
      users = User.name_equals("James")
      users.count.should eq(1)
      james = users.first
      james.name.should eq("James")
    end

    xit "checks against multiple" do 
      users = User.name_equals(["Ben","James"])
      binding.pry
      names = users.map { |u| u.name }
      names.count.should eq(2)
      names.should eq(["Ben","James"])
    end
  end

  it "can be chained with other scopes" do 
    james = User.create(:name=>"James", :age=>26)
    users = User.name_equals("James").age_equals(28)
    users.count.should eq(1)
    users.first.name.should eq("James")
    users.first.age.should eq(28)
  end
end