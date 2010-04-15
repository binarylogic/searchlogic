require File.expand_path(File.dirname(__FILE__) + "/../../spec_helper")

describe Searchlogic::NamedScopes::Ordering do
  it "should be dynamically created and then cached" do
    User.should_not respond_to(:ascend_by_username)
    User.ascend_by_username
    User.should respond_to(:ascend_by_username)
  end
  
  it "should have ascending" do
    %w(bjohnson thunt).each { |username| User.create(:username => username) }
    User.ascend_by_username.all.should == User.all(:order => "username ASC")
  end
  
  it "should have descending" do
    %w(bjohnson thunt).each { |username| User.create(:username => username) }
    User.descend_by_username.all.should == User.all(:order => "username DESC")
  end
  
  it "should have order" do
    User.order("ascend_by_username").proxy_options.should == User.ascend_by_username.proxy_options
  end

  it "should have order by custom scope" do
    User.column_names.should_not include("custom")
    %w(bjohnson thunt fisons).each { |username| User.create(:username => username) }
    User.named_scope(:ascend_by_custom, :order => "username ASC, name DESC")
    User.order("ascend_by_custom").proxy_options.should == User.ascend_by_custom.proxy_options
  end
  
  it "should have priorty to columns over conflicting association columns" do
    Company.ascend_by_users_count
  end
end
