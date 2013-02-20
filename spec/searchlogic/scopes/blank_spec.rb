require 'spec_helper'

describe Searchlogic::ActiveRecordExt::Scopes::Conditions::Blank do 
  before(:each) do 
    User.create(:name => "James")
  end

  it "should return user with null name" do 
    no_name = User.create
    no_name_id = no_name.id
    users = User.name_blank
    users.count.should eq(1)
    users.first.id.should eq(no_name_id)

  end
  it "should return user with empty string as name" do 
    no_name = User.create(:name=>"")
    no_name_id = no_name.id
    users = User.name_blank
    users.count.should eq(1)
    users.first.id.should eq(no_name_id)
  end

  it "should return user with empty string as name" do 
    no_name = User.create(:name=>false)
    no_name_id = no_name.id
    users = User.name_blank
    users.count.should eq(1)
    users.first.id.should eq(no_name_id)
  end
end