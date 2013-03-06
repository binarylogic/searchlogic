require 'spec_helper'

describe Searchlogic::ActiveRecordExt::Scopes::Conditions::Any do 
  before(:each) do 
    @james = User.create(:name=>"James")
    @jon = User.create(:name=>"Jon")
    @ben = User.create(:name=>"Ben")
  end

  it "finds either user specified" do 
    users = User.name_like_any("ame", "on")
    users.count.should eq(2)
    names = users.map(&:name)
    names.should eq(["James", "Jon"])
  end


  it "finds either user specified with an array" do 
    users = User.name_like_any(["ame", "on"])
    users.count.should eq(2)
    names = users.map(&:name)
    names.should eq(["James", "Jon"])
  end

  it "finds either user specified with multiple arguments " do 
    users = User.name_like_any("ame", "on")
    users.count.should eq(2)
    names = users.map(&:name)
    names.should eq(["James", "Jon"])
  end

  it "should do nothing if no arguments are passed" do 
    User.name_like_any.should eq(User.all)
  end

  it "should work with equals any and nil" do 
    User.create
    User.create
    User.name_equals_any( "Ben", nil).count.should eq(3)
  end 

  it "should have begins with any" do 
    tren = User.create(:name => "Tren")
    User.create(:name => "Tina")
    User.name_begins_with_any("J", "Tr").should eq([@james, @jon, tren])
  end

  it "should allow any on a has_many relationship" do
    company1 = Company.create
    user1 = company1.users.create
    company2 = Company.create
    user2 = company2.users.create
    user3 = company2.users.create

    Company.users_id_equals_any([user2.id, user3.id]).should eq([company2])
  end

  it "should return an active record relation" do 
    User.name_begins_with_any("J", "Tr").class.should eq(ActiveRecord::Relation)

  end

end