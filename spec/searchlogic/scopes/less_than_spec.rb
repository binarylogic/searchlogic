require 'spec_helper'

describe Searchlogic::ActiveRecordExt::Scopes::Conditions::LessThan do 
  before(:each) do 
    User.create(:name => "James", :age => 26, :created_at => DateTime.new(2012, 1, 12))
    User.create(:name => "Ben", :age => 30, :created_at => DateTime.new(2013, 2, 12))
    User.create(:name => "Tren", :age => 40, :created_at => DateTime.new(2012, 2, 17))
  end

  it "finds all other users less than specific age" do 
    find_users = User.age_less_than(27).map { |u| u.name }
    find_users.should eq(["James"])
  end
  it "parses datetime strings with chronic" do
    users = User.created_at_before("1 year ago")
    users.count.should eq(2)
    users.map(&:name).should eq(["James", "Tren"])
  end
end