require 'spec_helper'

describe Searchlogic::ActiveRecordExt::Scopes::Conditions::DoesNotBeginWith do 
  before(:each) do 
    User.create(:name=>"James")
    User.create(:name=>"BenJam")
    User.create(:name=>"TJamn")
  end

  it "finds users that do not begin with input" do 
    find_users = User.name_does_not_begin_with("Jam")
    user_names = find_users.map { |u| u.name }
    user_names.should eq(["BenJam", "TJamn"])
  end
end