require 'spec_helper'

describe Searchlogic::Conditions::BeginsWith do 
  before(:each) do 
    @james = User.new
    @james.name = "James"
    @james.save
  end

  it "should not match middle of work" do 
    User.name_begins_with("am").should be_empty
  end
  it "finds user based on beginning" do 
    User.name_begins_with("Jam").should_not be_empty
  end
end