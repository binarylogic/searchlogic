require 'spec_helper'

describe Searchlogic::SearchExt::Delegate do 
  before(:each) do 
    @james = User.create(:name=>"James", :age =>20, :username => "jvans1" )
    User.create(:name=>"James Vanneman", :age =>21, :username => "jvans1")
    @tren = User.create(:name => "Tren", :username =>"jvans")
    User.create(:name=>"Ben", :username =>"jvans1")
  end

  context "#delegate" do
    it "delegates to AR relation" do 
      search = User.searchlogic(:username_is => "jvans1")
      search.count.should eq(3)
    end

    it "should delegate the find_* method of active record" do 
      User.find_by_name("James").should eq(@james)
    end

    it "delegates with arguements" do 
      search = User.searchlogic(:username_is => "jvans1")
      james = search.find_by_name("James Vanneman")
      james.name.should eq("James Vanneman")
    end

    it "delegates" do 
      search = User.searchlogic(:name_like => "James")
      james = search.first
      james.name.should eq("James")
    end
  end

  context "#empty" do 
    it "should respond to empty" do 
      search = Order.search
      search.empty?.should be_true
    end
  end
end