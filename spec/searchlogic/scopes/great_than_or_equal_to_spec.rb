require 'spec_helper'
require 'pry'
describe Searchlogic::ActiveRecordExt::Scopes::Conditions::GreaterThanOrEqualTo do 
  before(:each) do 
    User.create(:name => "Tren", :age => 25, :created_at => DateTime.new(2020, 2, 2))
    User.create(:name => "James", :age => 26, :created_at => DateTime.new(2013, 8, 19))
    User.create(:name => "Ben", :age => 30, :created_at => DateTime.new(2010, 2, 2))
  end

  it "finds all other users greater than or equal to" do 
    find_users = User.age_greater_than_or_equal_to(26).map(&:name)
    find_users.should eq(["James" ,"Ben"])
  end
  it "parses datetime strings with chronic" do
    users = User.created_at_gte("Today")
    users.count.should eq(2)
    names = users.map(&:name)
    names.should eq(["Tren", "James"])
  end
end