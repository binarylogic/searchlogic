require 'spec_helper'

describe Searchlogic::Conditions::NotLike do 
  before(:each) do 
    @james = User.create(:name => "James")
    @ben = User.create(:name=>"Ben")
  end

  it "finds all other users besides partial name" do 
    find_users = User.name_not_like("am")
    not_ben = find_users.map(&:name)
    not_ben.should eq(["Ben"])
  end
end