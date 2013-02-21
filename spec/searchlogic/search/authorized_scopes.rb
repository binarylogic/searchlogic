require 'spec_helper'

describe Searchlogic::Search::AuthorizedScopes do 
  before(:each) do 
    User.create(:name=>"James", :age =>20, :username => "jvans1", :email => "jvannem@gmail.com" )
    User.create(:name=>"James Vanneman", :age =>21, :username => "jvans1")
    User.create(:name => "Tren")
    User.create(:name=>"Ben")
    Order.create
  end

  it "ignores unauthorized scopes on mass assignment" do 
    search = User.search(:username_eq => nil, :age_gt => 26, :destroy_all => true, :awesome => "AwesoemS")
    search.conditions.should eq({:age_gt=> 26 })
  end 
  it "doesn't let you write an unauthorized condition" do 
    search = User.search
    search.unauthorized = true
    search.conditions.empty?.should be_true
  end

end