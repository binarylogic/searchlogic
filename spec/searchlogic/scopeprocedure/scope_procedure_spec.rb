require 'spec_helper'

describe Searchlogic::ActiveRecordExt::ScopeProcedure::ClassMethods do 
  before(:each) do 
    User.create(:name=>"James", :age =>20, :username => "jvans1", :email => "jvannem@gmail.com" )
    User.create(:name=>"James Vanneman", :age =>21, :username => "jvans1")
    User.create(:name => "Tren")
    User.create(:name=>"Ben")
    Order.create(:total => "450")
    # User.scope_procedure(:cool){ :conditions => {:name_like => "James", :age_gt => 20}}
    # User.scope_procedure(:super_cool){ User.name_equals("James Vanneman")}
    # Order.scope_procedure(:large){Order.total_gt(400)}
    # LineItem.scope_procedure(:expensive){LineItem.price_gt(15)}
  end
  after(:each) do 
    User.searchlogic_scopes.clear
    Order.searchlogic_scopes.clear
  end
  xit "creates a scope procedure" do    
    User.cool.count.should eq(1)
    User.cool.first.name.should eq("James Vanneman")  
  end

  xit "keeps track of scope procedures for individual classes" do 
    User.searchlogic_scopes.should eq([:cool, :super_cool])
    Order.searchlogic_scopes.should eq([:large])
  end
end

