require 'spec_helper'

describe Searchlogic::ActiveRecordExt::Scopes::Conditions::GreaterThanOrEqualTo do 
  before(:each) do 
    @joe = User.create(:name => "Joe", :age => 25)
    @james = User.create(:name => "James", :age => 26)
    @ben = User.create(:name => "Ben", :age => 30)
  end

  it "finds all other users greater than or equal to" do 
    find_users = User.age_less_than_or_equal_to(26).map { |u| u.name }
    find_users.should eq(["Joe" ,"James"])
  end
  xit "parses datetime strings with chronic" do


  end
end