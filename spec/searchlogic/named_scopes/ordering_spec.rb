require 'spec_helper'

describe Searchlogic::NamedScopes::Ordering do
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
    User.scope(:ascend_by_custom, :order => "username ASC, name DESC")
    User.order("ascend_by_custom").proxy_options.should == User.ascend_by_custom.proxy_options
  end

  it "should have priorty to columns over conflicting association columns" do
    Company.ascend_by_users_count
  end
end
