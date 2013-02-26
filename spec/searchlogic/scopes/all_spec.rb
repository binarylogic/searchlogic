require 'spec_helper'

describe Searchlogic::ActiveRecordExt::Scopes::Conditions::Any do 
  before(:each) do 
    @james = User.create(:name => "James")
    @james_ben = User.create(:name=>"JamesBen")
    User.create(:name=>"Jon")
    @ben = User.create(:name=>"Ben")
  end

  it "finds users specified by both conditions" do 
    users = User.name_like_all("James", "Ben")
    users.count.should eq(1)
    
    names = users.map(&:name)
    names.should eq(["JamesBen"])
  end


  it "finds users specified by both conditions with an array" do 
    users = User.name_like_all(["James", "Ben"])
    users.count.should eq(1)
    names = users.map(&:name)
    names.should eq(["JamesBen"])
  end
end