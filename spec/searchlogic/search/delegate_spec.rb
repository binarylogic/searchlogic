require 'spec_helper'

describe Searchlogic::SearchExt::Delegate do 
  before(:each) do 
    User.create(:name=>"James", :age =>20, :username => "jvans1" )
    User.create(:name=>"James Vanneman", :age =>21, :username => "jvans1")
    User.create(:name => "Tren", :username =>"jvans")
    User.create(:name=>"Ben", :username =>"jvans1")
  end

  it "delegates to AR relation" do 
    search = User.searchlogic(:username_is => "jvans1")
    search.count.should eq(3)
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