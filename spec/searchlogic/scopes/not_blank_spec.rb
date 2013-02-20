require 'spec_helper'

describe Searchlogic::ActiveRecordExt::Scopes::Conditions::NotBlank do 
  before(:each) do 
    User.create(:name => "James")
    User.create(:name => "")
    User.create(:name => false)
    User.create(:name => nil)
    User.create
  end

  it "should return user with the name" do 
    users = User.name_not_blank
    users.count.should eq(1)
    users.first.name.should eq("James")
  end

end