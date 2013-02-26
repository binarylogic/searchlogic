require 'spec_helper'

describe "Searchlogic::SearchExt::ScopeProcedure" do
  it "should create a search proxy" do
    User.search(:username => "joe").should be_kind_of(Searchlogic::Search)
  end
  it "should create a search proxy using the same class" do
    User.search.klass.should == User
  end

  it "should pass on the current scope to the proxy" do
    company = Company.create
    user = company.users.create
    search = company.users.search
    search.all.should eq(company.users)
  end
  it "should respond to empty" do 
    search = Order.search
    search.empty?.should be_true
  end
  
end