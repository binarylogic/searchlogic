require 'spec_helper'

describe Searchlogic::Conditions::GreaterThan do 
  before(:each) do 
    @james = User.new
    @james.name = "James"
    @james.age = 26
    @james.save
    @ben = User.new
    @ben.name = "Ben"
    @ben.age = 30
    @ben.save
  end

  it "finds all other users greater than" do 
    find_users = User.age_greater_than(27).map { |u| u.name }
    find_users.should eq(["Ben"])
  end
end