require 'spec_helper'

describe Searchlogic::Conditions::Null do 
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
    no_name_id = no_name.id
    find_users = User.name_null.map { |u| u.id }
    find_users.should eq([no_name_id])
  end
end