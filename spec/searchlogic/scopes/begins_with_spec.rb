require 'spec_helper'

describe Searchlogic::ActiveRecordExt::Scopes::Conditions::BeginsWith do 
  before(:each) do 
    @james = User.create(:name=>"James", :age=>26)
  end

  it "should not match middle of work" do 
    User.name_begins_with("am").should be_empty
  end
  it "finds user based on beginning" do 
    users = User.name_begins_with("Jam")
    users.count.should eq(1)
    users.first.name.should eq("James")
  end

  it "can be chained" do  
    User.create(:name=>"Jarule", :age=>28)
    find_james = User.name_begins_with("Ja").age_equals(26)
    find_james.count.should eq(1)
    find_james.first.name.should eq("James")
  end
end