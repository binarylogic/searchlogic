require 'spec_helper'

describe Searchlogic::ActiveRecordExt::Scopes::Conditions::DoesNotEqual do 
  before(:each) do 
    User.create(:name => "James")
    User.create(:name => "Bob")
    @bob2 = User.create(:name => "Bob", :age => 10)
    @bob3 = User.create(:name => "Bob", :age => 10)
    @bob4 = User.create(:name => "Bob", :age => 10)

  end

  it "finds users that do not equal input" do 
    find_bobs = User.name_does_not_equal("James")
    find_bobs.count.should eq(4)
  end

  it "takes an array of values" do 
    users = User.id_does_not_equal(1,2,3)
    users.count.should eq(2)
    ids = users.map(&:id)
    ids.should eq([4,5])
  end

  it "works with nil values" do 
    users = User.age_not_equal(nil).should eq([@bob2, @bob3, @bob4])

  end
end