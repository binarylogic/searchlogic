require 'spec_helper'

describe Searchlogic::Conditions::Aliases do 
  before(:each) do 
    @james = User.create(:name=>"James")
    User.create(:name=>"Jon")
    @ben = User.create(:name=>"Ben")
  end

  it "finds users via aliases" do 
    users = User.name_like_any("ame", "on")
    users.count.should eq(2)
    names = users.map(&:name)
    names.should eq(["James", "Jon"])
  end

end