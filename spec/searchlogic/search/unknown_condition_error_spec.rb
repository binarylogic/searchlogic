require 'spec_helper'

describe Searchlogic::SearchExt::UnknownConditionError do 
  before(:each) do 
    User.create(:name=>"James", :age =>20, :username => "jvans1", :email => "jvannem@gmail.com" )
    User.create(:name=>"James Vanneman", :age =>21, :username => "jvans1")
    User.create(:name => "Tren")
    User.create(:name=>"Ben")
    Order.create
  end

  it "doesn't let you assign unauthorized conditions" do 
    search = User.searchlogic
    expect{search.authorize = true }.to  raise_error
  end


  it "doesn't let you assign harmful conditions" do 
    search = User.searchlogic
    expect{search.destroy = true }.to raise_error
  end

  it "shoudl be raised when omit " do 
    search = LineItem.search(:order => :descend_order_user_id)
    expect{search.all}.to raise_error Searchlogic::ActiveRecordExt::Scopes::InvalidConditionError
  end



end