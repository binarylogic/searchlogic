require File.expand_path(File.dirname(__FILE__) + "/../../spec_helper")

describe "Searchlogic::ActiveRecord::AssociationProxy" do
  it "should call location conditions" do
    company = Company.create
    user = company.users.create(:username => "bjohnson")
    company.users.send(:username_like, "bjohnson").should == [user]
  end
  
  it "should call ordering conditions" do
    company = Company.create
    user = company.users.create(:username => "bjohnson")
    company.users.send(:ascend_by_username).should == [user]
  end
  
  it "should call 'or' conditions" do
    company = Company.create
    user = company.users.create(:username => "bjohnson")
    company.users.send(:username_or_some_type_id_like, "bjohnson").should == [user]
  end
    
end

