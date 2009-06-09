require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe "Ordering" do
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
end
