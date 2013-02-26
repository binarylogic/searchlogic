require 'spec_helper'

describe "Searchlogic::SearchExt::ScopeProcedure" do 
  before(:each) do
    User.scope_procedure(:young, { :age_lt => 21 })
    # User.scope_procedure :awesome, lambda { :name_like => "James")}
    User.create(:name=>"James", :age =>20, :username => "jvans1", :email => "jvannem@gmail.com" )
    User.create(:name=>"James Vanneman", :age =>21, :username => "jvans1")
    User.create(:name => "Tren")
    User.create(:name=>"Ben")
  end
  xit "creates a scopes procedure" do 
    users = User.young
    users.count.should eq(1)
    users.name.should eq("James")
  end

  xit "can be called with multiple scope procecures" do 
    search = User.search(:awesome => true, :young => true)
    search.count.should eq(1)
    search.map(&:name).should eq(["James"])
  end

  xit "doesn't call scope procecure when left out" do 
    search = User.search
    search.count.should eq(4)
    search.map(&:name).should eq(["James", "James Vanneman", "Tren", "Ben"])
  end
  
  xit "doesn't call scope procedure when assigned false" do 
    search = User.search(:awesome => true, :young => false)
    search.count.should eq(2)
    search.map(&:name).should eq(["James", "James Vanneman"])    
  end
  
  xit "should use custom scopes before normalizing" do
    User.scope_procedure(:cust_username){ |value| {:username => value.reverse}}
    search1 = User.search(:cust_username => "jvans1")
    search2 = User.search(:cust_username => "1snavj")    
    search1.count.should eq(0)
    search2.count.should eq(2)
  end
end