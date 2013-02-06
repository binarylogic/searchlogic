require 'spec_helper'

describe Searchlogic::Conditions::DescendBy do 
  before(:each) do 
    @james = User.create(:name=>"James")
    @ben = User.create(:name=>"Ben")
  end

  it "orders users based on id" do 
    User.create(:name=>"Jon")
    users = User.descend_by_id
    user_ids = users.map(&:id)
    user_ids.should eq([3,2,1])
  end
end