require 'spec_helper'

describe Searchlogic::Search::SearchProxy::CountConditions do 
  before(:each) do 
    User.create(:name=>"James", :age =>20, :username => "jvans1" )
    User.create(:name=>"James Vanneman", :age =>21, :username => "jvans1")
    User.create(:name => "Tren", :username =>"jvans")
    User.create(:name=>"Ben", :username =>"jvans1")
  end

  it "returns the count" do 
    search = User.search(:username_is => "jvans1")
    search.count.should eq(3)
  end
end