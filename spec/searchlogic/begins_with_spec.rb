require 'spec_helper'

describe Searchlogic::Conditions::BeginsWith do 
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
end