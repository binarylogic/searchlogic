require 'spec_helper'

describe Searchlogic::Base do 
  before(:each) do 
    User.create(:name=>"James", :age =>20, :username => "jvans1", :email => "jvannem@gmail.com" )
    User.create(:name=>"James Vanneman", :age =>21, :username => "jvans1")
    User.create(:name => "Tren")
    User.create(:name=>"Ben")
  end

  it "ignores nil on mass assignment" do 
    search = User.searchlogic(:username_eq => nil, :name_like =>"James")
    search.count.should eq(2)
    search.all.map(&:name).should eq(["James", "James Vanneman"])
  end


end