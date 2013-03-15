require 'spec_helper'

describe Searchlogic::ActiveRecordExt::Scopes::Conditions::All do 
  before(:each) do 
    @james = User.create(:name => "James")
    @james_ben = User.create(:name=>"JamesBen")
    User.create(:name=>"Jon")
    @ben = User.create(:name=>"Ben")
  end

  it "finds users specified by both conditions" do 
    users = User.name_like_all("James", "Ben")
    users.count.should eq(1)
    
    names = users.map(&:name)
    names.should eq(["JamesBen"])
  end 

  it "finds users specified by both conditions with an array" do 
    users = User.name_like_all(["James", "Ben"])
    users.count.should eq(1)
    names = users.map(&:name)
    names.should eq(["JamesBen"])
  end

  it "doesn't throw an error with 1 argument" do
    users = User.name_like_all("James")
    users.should eq([@james, @james_ben])
  end

  it "works with or conditions" do
    users = User.search(:orders_line_items_price_gt => 5, :name_or_username_like_all => ["ja","m"], :order => :descend_by_orders_name)
    expect {users.all}.to_not raise_error
  end
end