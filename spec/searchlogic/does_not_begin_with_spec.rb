require 'spec_helper'

describe Searchlogic::Conditions::DoesNotBeginWith do 
  before(:each) do 
    @james = User.create(:name=>"James")
    @ben = User.create(:name=>"Ben")
  end

  it "finds users that do not begin with input" do 
    find_users = User.name_does_not_begin_with("Jam")
    user_names = find_users.map { |u| u.name }
    user_names.should eq(["Ben"])
  end
end