require 'spec_helper'

describe Searchlogic::ActiveRecordExt::Scopes::Conditions::DoesNotEndWith do 
  before(:each) do 
    User.create(:name=>"James")
    User.create(:name => "Jamess")
    User.create(:name => "Bob")
  end

  it "finds users that do not end with input" do 
    find_users = User.name_does_not_end_with("mes")
    user_names = find_users.map { |u| u.name }
    user_names.should eq(["Jamess", "Bob"])
  end
end