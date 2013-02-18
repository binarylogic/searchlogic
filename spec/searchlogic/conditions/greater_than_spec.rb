require 'spec_helper'

describe Searchlogic::Conditions::GreaterThan do 
  before(:each) do 
    @james = User.create(:name => "James", :age => 26)
    @ben = User.create(:name => "Ben", :age => 30)
    @Tren = User.create(:name => "Tren", :age => 27)

  end

  it "finds all other users greater than" do 
    find_users = User.age_gt(26).map { |u| u.name }
    find_users.should eq(["Ben", "Tren"])
  end
end