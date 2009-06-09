require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

describe "Search" do
  it "should create a search proxy" do
    User.search(:username => "joe").should be_kind_of(Searchlogic::SearchProxy)
  end
  
  it "should create a search proxy using the same class" do
    User.search.klass.should == User
  end
  
  it "should pass on the current scope to the proxy" do
    company = Company.create
    user = company.users.create
    search = company.users.search
    search.current_scope.should == company.users.scope(:find)
  end
end