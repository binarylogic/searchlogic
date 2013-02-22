require 'spec_helper'

describe Searchlogic::ActiveRecordExt::Scopes::Conditions::NotNull do 
  before(:each) do 
    User.create(:name => "James")
    User.create(:name => "Ben")
  end

  it "finds all users with null name" do 
    no_name = User.new
    no_name.name = nil
    no_name.save
    find_users = User.name_not_null.map { |u| u.name }
    find_users.should eq(["James", "Ben"])
  end
end