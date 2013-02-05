require 'spec_helper'

describe Searchlogic::Conditions::Blank do 
  before(:each) do 
    @james = User.new
    @james.name = "James"
    @james.save
  end

  it "should return user with null name" do 
    no_name = User.new
    no_name.name = nil
    no_name.save
    no_name_id = no_name.id
    users = User.name_blank
    users.count.should eq(1)
    users.first.id.should eq(no_name_id)

  end
  it "should return user with empty string as name" do 
    no_name = User.new
    no_name.name = ""
    no_name.save
    no_name_id = no_name.id
    users = User.name_blank
    users.count.should eq(1)
    users.first.id.should eq(no_name_id)
  end

  it "should return user with empty string as name" do 
    no_name = User.new
    no_name.name = false
    no_name.save
    no_name_id = no_name.id
    users = User.name_blank
    users.count.should eq(1)
    users.first.id.should eq(no_name_id)
  end
end