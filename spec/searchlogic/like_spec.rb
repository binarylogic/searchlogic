require 'spec_helper'

describe Searchlogic::Conditions::Like do 
  before(:each) do 
    @james = User.create(:name=> "Vanneman")
    @ben = User.create(:name=>"Johnson")
  end

  it "finds user based on partial name" do 
    users = User.name_like("ann")
    users.count.should eq(1)
    users.first.name.should eq("Vanneman")
  end
end