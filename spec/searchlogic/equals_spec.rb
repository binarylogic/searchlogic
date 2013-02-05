require 'spec_helper'

describe Searchlogic::Conditions::Equals do
  before(:each) do 
    james = User.new
    james.name = "James"
    james.save
  end
  describe "Equals Query on Single Column" do 
    it "returns the user when column exists"  do 

      User.name_equals("James").should_not be_empty
    end

  end
end