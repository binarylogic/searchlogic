require 'spec_helper'

describe Searchlogic::Conditions::Equals do
  before(:each) do 
    @james = User.new
    @james.name = "James"
    @james.save
  end
  describe "Equals Query on Single Column" do 
    it "returns the user when column exists"  do 
      User.name_equals("James").should_not be_empty
    end
    xit "and raises NoMethodError when column doesn't exist" do 
      User.titties_equals("Big").should_raise NoMethodError
    end 
  end

  describe "Equals Query on multiple Columns" do 
    xit "chains two queries together" do 
      @james = User.new
      @james.name = "James"
      @james.save
      @james.age = 26
      @james.save 
      User.name_equals("James").age_equals(26).should_not be_empty
    end
  end
end