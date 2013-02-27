require 'spec_helper'

describe Searchlogic::SearchExt::UnknownConditionError do 
  before(:each) do 
    User.create(:name=>"James", :age =>20, :username => "jvans1", :email => "jvannem@gmail.com" )
    User.create(:name=>"James Vanneman", :age =>21, :username => "jvans1")
    User.create(:name => "Tren")
    User.create(:name=>"Ben")
    Order.create
  end

  xit "doesn't let you assign unauthorized conditions" do 
    search = User.searchlogic
    lambda{search.authorize = true }.should raise_error Searchlogic::SearchExt::UnknownConditionError
  end


  xit "doesn't let you assign harmful conditions" do 
    search = User.searchlogic
    lambda{search.destroy = true }.should raise_error Searchlogic::SearchExt::UnknownConditionError
  end

end