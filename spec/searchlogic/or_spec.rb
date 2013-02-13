require 'spec_helper'

describe Searchlogic::Conditions::Oor do 
  before(:each) do 
    @james2 = User.create(:name => "Vanneman")
    @bill = User.create(:name => "Bill", :username => "Bill_Vanneman_JR")
    @james = User.create(:name=>"James")
    @ben = User.create(:name=>"Ben", :username => "america", :email => "Ben@Vanneman")
    @tren = User.create(:name=> "Tren", :username => "ANTJamesan")
    @john = User.create(:name => "John", :username => "amicus")
  end

  it "gathers users based on OR condition" do 
    users = User.username_like_or_name_like("ame")
    users.count.should eq(3)
    usernames = users.map(&:name)

    usernames.should eq(["Ben", "Tren", "James"])
  end

  it "gathers users based on OR condition omiting first compairson" do 
    users = User.username_or_name_like("ame")
    users.count.should eq(3)
    usernames = users.map(&:name)
    usernames.should eq(["Ben", "Tren", "James"])
  end


  it "gathers users based on OR with two different conditions" do 
    users = User.username_like_or_name_equals("James")
    users.count.should eq(2)
    names = users.map(&:name)
    names.should eq(["Tren", "James"])
  end

  it "gather users based on OR with three conditions" do 
    users = User.username_like_or_name_equals_or_email_ends_with("Vanneman")
    users.count.should eq(3)
    names = users.map(&:name)
    names.should eq(["Bill", "Vanneman", "Ben"])
  end

  it "gathers three OR conditions omitting specific conditions until end" do 
    users = User.username_or_name_or_email_like("Vanneman")
    users.count.should eq(3)
    names = users.map(&:name)
    names.should eq(["Bill", "Vanneman", "Ben"])
  end


  
end