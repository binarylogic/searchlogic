require 'spec_helper'

describe Searchlogic::Conditions::Oor do 
  before(:each) do 
    @james = User.create(:name=>"James")
    @ben = User.create(:name=>"Ben", :username => "america")
    @tren = User.create(:name=> "Tren", :username => "ANTJamesan")
    @john = User.create(:name => "John", :username => "amicus")
  end

  it "gathers users based on OR condition" do 
    users1 = User.username_or_name_like("ame")
    users2 = User.username_like_or_name_like("ame")
    users1.count.should eq(3)
    users1.should eq(users2)
    usernames = users1.map(&:name)
    usernames.should eq(["Ben", "Tren", "James"])
  end


  it "gathers users based on OR with two different conditions" do 
    users = User.username_like_or_name_equals("James")
    users.count.should eq(2)
    names = users.map(&:name)
    names.should eq(["Tren", "James"])
  end


  
end