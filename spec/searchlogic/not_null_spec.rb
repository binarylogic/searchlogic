require 'spec_helper'

describe Searchlogic::Conditions::NotNull do 
  before(:each) do 
    @james = User.new
    @james.name = "James"
    @james.save
    @ben = User.new
    @ben.name = "Ben"
    @ben.save
  end

  it "finds all users with null name" do 
    no_name = User.new
    no_name.name = nil
    no_name.save
    find_users = User.name_not_null.map { |u| u.name }
    find_users.should eq(["James", "Ben"])
  end
end