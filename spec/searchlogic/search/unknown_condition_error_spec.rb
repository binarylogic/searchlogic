require 'spec_helper'

describe Searchlogic::SearchExt::UnknownConditionError do 
  before(:each) do 
    User.create(:name=>"James", :age =>20, :username => "jvans1", :email => "jvannem@gmail.com" )
    User.create(:name=>"James Vanneman", :age =>21, :username => "jvans1")
    User.create(:name => "Tren")
    User.create(:name=>"Ben")
    Order.create
  end

  xit "handles unknown condition error" do 
    search = User.searchlogic(:age_eq => 24)
    search.authorize.should_raise UnknownConditionError
  end

end