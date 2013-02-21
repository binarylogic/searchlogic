require 'spec_helper'

describe Searchlogic::Search::MixinEnumerable do 
  before(:each) do 
    User.create(:name=>"James", :age =>20, :username => "jvans1" )
    User.create(:name=>"James Vanneman", :age =>21, :username => "jvans1")
    User.create(:name => "Tren", :username =>"jvans")
    User.create(:name=>"Ben", :username =>"jvans1")
  end

  it "Acts as an enumerable" do 
    search = User.search
    binding.pry
    search.should_respond_to(:map)
  end


end