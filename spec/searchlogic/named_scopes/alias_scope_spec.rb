require 'spec_helper'

describe Searchlogic::NamedScopes::AliasScope do
  before(:each) do
    User.alias_scope :username_has, lambda { |value| User.username_like(value) }
  end
  
  it "should allow alias scopes" do
    User.create(:username => "bjohnson")
    User.create(:username => "thunt")
    User.username_has("bjohnson").all.should == User.find_all_by_username("bjohnson")
  end
  
  it "should allow alias scopes with symbols" do
    User.alias_scope :login_has, :username_has
    User.create(:username => "bjohnson")
    User.create(:username => "thunt")
    User.login_has("bjohnson").all.should == User.find_all_by_username("bjohnson")
  end
  
  it "should allow alias scopes from the search object" do
    search = User.search
    search.username_has = "bjohnson"
    search.username_has.should == "bjohnson"
  end
  
  it "should inherit alias scopes from superclasses" do
    Class.new(User).condition?("username_has").should be_true
  end
end
