require 'spec_helper'

describe Searchlogic::Conditions::EndsWith do 
  before(:each) do 
    @james = User.new
    @james.name = "James"
    @james.save
    @ben = User.new
    @ben.name = "Ben"
    @ben.save
  end

  it "should not match middle of work" do 
    User.name_begins_with("am").should be_empty
  end
  it "finds user based on end" do 
    james = User.name_ends_with("mes")
    james.count.should eq(1)
    james.first.name.should eq("James")
  end
end