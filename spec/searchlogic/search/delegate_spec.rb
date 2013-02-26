require 'spec_helper'

describe Searchlogic::SearchExt::Delegate do 
  before(:each) do 
    User.create(:name=>"James", :age =>20, :username => "jvans1" )
    User.create(:name=>"James Vanneman", :age =>21, :username => "jvans1")
    User.create(:name => "Tren", :username =>"jvans")
    User.create(:name=>"Ben", :username =>"jvans1")
  end

  context "#sanitize_conditions" do 
    it "should ignore blank values but still return on conditions" do
      search = User.search
      search.conditions = {"username" => ""} 
      search.send('sanitized_conditions').should eq({})

    end
    it "should ignore blank values in arrays" do
      search = User.search
      search.conditions = {"username_equals_any" => [""]}
      search.username_equals_any.should eq([""])
      search.all.should eq(User.all)
      search.conditions = {"id_equals_any" => ["", "1"]}
      search.all.should eq([User.find(1)])      
    end
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