require 'spec_helper'

describe Searchlogic::Conditions::DoesNotEndWith do 
  before(:each) do 
    @james = User.create(:name=>"James")
    @bob = User.create(:name => "Bob")
  end

  it "finds users that do not end with input" do 
    find_users = User.name_does_not_end_with("mes")
    user_names = find_users.map { |u| u.name }
    user_names.should eq(["Bob"])
  end
end