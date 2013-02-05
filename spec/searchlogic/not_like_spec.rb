require 'spec_helper'

describe Searchlogic::Conditions::NotLike do 
  before(:each) do 
    @james = User.new
    @james.name = "James"
    @james.save
    @ben = User.new
    @ben.name = "Ben"
    @ben.save
  end

  it "finds all other users besides partial name" do 
    find_users = User.name_not_like("am").map { |u| u.name }
    find_users.should eq(["Ben"])
  end
end