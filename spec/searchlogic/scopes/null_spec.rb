require 'spec_helper'

describe Searchlogic::ActiveRecordExt::Scopes::Conditions::Null do 
  before(:each) do 
    @james = User.create(:name => "James")
    @ben = User.create(:name => "Ben")
    @no_name = User.create
  end

  it "finds all users with null name" do 
    no_name_id = @no_name.id
    find_users = User.name_null.map { |u| u.id }
    find_users.should eq([no_name_id])
  end
end