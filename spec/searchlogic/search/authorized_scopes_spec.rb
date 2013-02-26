require 'spec_helper'

describe Searchlogic::SearchExt::AuthorizedScopes do 
  before(:each) do 
    o1 = Order.create(:total => 15)
    o2 = Order.create(:total => 10)
    o3 = Order.create(:total => 10)
    o4 = Order.create(:total =>9)
    o5 = Order.create(:total => 10)    
    o6 = Order.create(:total => 12)    

    @james = User.create(:name=>"James", :orders => [o1,o3], :age =>20, :username => "jvans1", :email => "jvannem@gmail.com" )
    User.create(:name=>"James Vanneman", :age =>21, :username => "jvans1", :orders => [o6])
    @tren  = User.create(:name => "Tren", :orders => [o5,o2])
    @ben = User.create(:name=>"Ben", :orders => [o4])

  end

  it "ignores unauthorized scopes on mass assignment" do 
    search = User.search(:username_eq => nil, :age_gt => 26, :destroy_all => true, :awesome => "AwesoemS")
    search.conditions.should eq({:age_gt=> 26 })
  end 
  
  xit "doesn't let you write an unauthorized condition" do 
    search = User.search
    search.unauthorized = true
    search.conditions.empty?.should be_true
  end

  it "lets you write methods on associationed columns" do 
    search = User.search 
    search.orders_total = 10
    search.all.should eq([@tren, @james])
  end

end