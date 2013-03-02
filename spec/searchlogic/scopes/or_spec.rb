require 'spec_helper'

describe Searchlogic::ActiveRecordExt::Scopes::Conditions::Oor do 
  before(:each) do 
    User.create(:name => "Vanneman")
    User.create(:name => "Bill", :username => "Bill_Vanneman_JR")
    User.create(:name=>"James")
    User.create(:name=>"Ben", :username => "america", :email => "Ben@Vanneman")
    User.create(:name=> "Tren", :username => "ANTJamesan")
    User.create(:name => "John", :username => "amicus")
  end

  it "gathers users based on OR condition" do 
    users = User.username_like_or_name_like("ame")
    users.count.should eq(3)
    usernames = users.map(&:name)

    usernames.should eq(["James", "Ben", "Tren" ])
  end

  it "works with 'or' in first method" do 
    users = User.id_greater_than_or_equal_to_or_age_lt(4)
  end 

  xit "works with chaine of associations" do 

  end
  xit 'workd with a long chain of ors' do 


  end
  it "gathers users based on OR condition omiting first compairson" do 
    users = User.username_or_name_like("ame")
    users.count.should eq(3)
    usernames = users.map(&:name)
    usernames.should eq(["James", "Ben", "Tren" ])
  end

  it "should not get confused by the 'or' in find_or_create_by_* methods" do
    User.create(:name => "Fred")
    User.find_or_create_by_name("Fred").should be_a_kind_of User
  end

  it "should not get confused by the 'or' in compound find_or_create_by_* methods" do
    User.create(:name => "Fred", :username => "fredb")
    User.find_or_create_by_name_and_username("Fred", "fredb").should be_a_kind_of User
  end
  

  it "gathers users based on OR with two different conditions" do 
    users = User.username_like_or_name_equals("James")
    users.count.should eq(2)
    names = users.map(&:name)
    names.should eq(["James", "Tren"])
  end

  it "gather users based on OR with three conditions" do 
    users = User.username_like_or_name_equals_or_email_ends_with("Vanneman")
    users.count.should eq(3)
    names = users.map(&:name)
    names.should eq(["Vanneman", "Bill", "Ben"])
  end

  it "gathers three OR conditions omitting specific conditions until end" do 
    users = User.username_or_name_or_email_like("Vanneman")
    users.count.should eq(3)
    names = users.map(&:name)
    names.should eq(["Vanneman", "Bill", "Ben"])
  end


  
end