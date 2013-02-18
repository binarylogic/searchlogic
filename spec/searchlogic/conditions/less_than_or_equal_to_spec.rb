require 'spec_helper'

describe Searchlogic::Conditions::GreaterThanOrEqualTo do 
  before(:each) do 
    @joe = User.new
    @joe.name = "Joe"
    @joe.age = 25
    @joe.save
    @james = User.new
    @james.name = "James"
    @james.age = 26
    @james.save
    @ben = User.new
    @ben.name = "Ben"
    @ben.age = 30
    @ben.save
  end

  it "finds all other users greater than or equal to" do 
    find_users = User.age_less_than_or_equal_to(26).map { |u| u.name }
    find_users.should eq(["Joe" ,"James"])
  end
end