require 'spec_helper'

describe Searchlogic::ActiveRecordExt::ScopeProcedure::ClassMethods do 
  before(:each) do 
    User.create(:name=>"James", :age =>20, :username => "jvans1", :email => "jvannem@gmail.com" )
    User.create(:name=>"James Vanneman", :age =>21, :username => "jvans1")
    User.create(:name => "Tren")
    User.create(:name=>"Ben")
  end
  it "creates a scope procedure" do 
    User.scope_procedure(:cool){ puts "Woo I'm cool"}
  end
end

