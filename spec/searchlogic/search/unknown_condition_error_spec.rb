require 'spec_helper'

describe Searchlogic::Search::UnknownConditionError do 
  before(:each) do 
    User.create(:name=>"James", :age =>20, :username => "jvans1", :email => "jvannem@gmail.com" )
    User.create(:name=>"James Vanneman", :age =>21, :username => "jvans1")
    User.create(:name => "Tren")
    User.create(:name=>"Ben")
    Order.create
  end

  it "handles unknown condition error" do 
    search = User.searchlogic(:age_eq => 24)
    search.authorize.should_raise UnknownConditionError
  end

end