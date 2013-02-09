require 'spec_helper'

describe Searchlogic::Conditions::Like do 
  before(:each) do 
    User.create(:name => "man", :username => "anders")
    @james = User.create(:name=> "Vanneman", :username => "jvans")
    @ben = User.create(:name=>"Janson", :username => "eman")
  end

  it "finds user based on partial name" do 
    users = User.name_like("ann")
    users.count.should eq(1)
    users.first.name.should eq("Vanneman")
  end

  xit "returns all users who have either name with 'any' clause" do 
    users = User.name_like_any("Vanneman", "Janson")
    users.count.should eq(2)
    user_names = users.map(&:name)
    user_names.should eq(["Vanneman", "Janson"])
  end
end