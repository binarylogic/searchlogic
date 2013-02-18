require 'spec_helper'

describe Searchlogic::Search::SearchProxy::Attributes do 
  before(:each) do 
    User.create(:name=>"James", :age =>20, :username => "jvans1" )
    User.create(:name=>"James Vanneman", :age =>21, :username => "jvans1")
    User.create(:name => "Tren")
    User.create(:name=>"Ben")
  end

  it "has readers for conditions" do
    search = User.search(:name_ew => "man")
    search.name_ew.should eq("man")
  end
end