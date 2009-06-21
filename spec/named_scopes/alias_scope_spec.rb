require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe "AliasScope" do
  it "should allow alias scopes" do
    User.create(:username => "bjohnson")
    User.create(:username => "thunt")
    User.username_has("bjohnson").all.should == User.find_all_by_username("bjohnson")
  end
  
  it "should allow alias scopes from the search object" do
    search = User.search
    search.username_has = "bjohnson"
    search.username_has.should == "bjohnson"
  end
end