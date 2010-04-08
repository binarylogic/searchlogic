require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe "AssociationProxyOverride" do
  it "should allow #send to work proplery on associations for conditions" do
    company = Company.create
    user = company.users.create(:username => "bjohnson")
    company.users.send(:username_is, "bjohnson").should == [user]
  end
  
  it "should allow #send to work proplery on associations for ordering" do
    company = Company.create
    user = company.users.create(:username => "bjohnson")
    company.users.send(:ascend_by_username, "bjohnson").should == [user]
  end
  
  it "should allow #send to work proplery on associations for ordering" do
    company = Company.create
    user = company.users.create(:username => "bjohnson")
    company.users.send(:username_or_some_type_id_is, "bjohnson").should == [user]
  end
    
end

