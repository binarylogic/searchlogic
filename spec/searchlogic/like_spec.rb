require 'spec_helper'

describe Searchlogic::Conditions::Like do 
  before(:each) do 
    @james = User.new
    @james.name = "James"
    @james.save
  end
  it "finds user based on partial name" do 
    User.name_like("am").should_not be_empty
  end
end