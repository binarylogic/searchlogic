require 'spec_helper'

describe Searchlogic::ActiveRecordExt::Scopes::Conditions::GreaterThanOrEqualTo do 
  before(:each) do 
    User.create(:name => "Joe", :age => 25, :create_at => DateTime.new(2012,2,30))
    User.create(:name => "James", :age => 26, :create_at => DateTime.new(2012,2,12))
    User.create(:name => "Ben", :age => 30, :create_at => DateTime.new(2012,1,12))
  end

  it "finds all other users greater than or equal to" do 
    find_users = User.age_less_than_or_equal_to(26).map { |u| u.name }
    find_users.should eq(["Joe" ,"James"])
  end
  it "parses datetime strings with chronic" do
    users = User.created_at_before("1 year ago")
    users.count.should eq(2)
    names = users.map(&:name)
    names.should eq(["James", "Ben"])

  end
end