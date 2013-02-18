require 'spec_helper'

describe Searchlogic::Search::SearchProxy::Base do 
  before(:each) do 
    @james = User.create(:name=>"James", :age =>20, :username => "jvans1" )
    @james = User.create(:name=>"James Vanneman", :age =>21, :username => "jvans1")

    @ben = User.create(:name=>"Ben")
  end

  describe "Proxy Object" do 
    it "sets conditions on initialize" do
      search = User.search(:name_like => "James", :age_gt => 20, :username_eq => "jvans1")
      search.conditions.should eq({:name_like => "James", :age_gt => 20, :username_eq => "jvans1"})
    end
  end
end