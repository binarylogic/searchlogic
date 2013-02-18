require 'spec_helper'

describe Searchlogic::Search::SearchProxy::AttributesReaderWriters do 
  before(:each) do 
    @james = User.create(:name=>"James", :age =>20, :username => "jvans1" )
    @james = User.create(:name=>"James Vanneman", :age =>21, :username => "jvans1")

    @ben = User.create(:name=>"Ben")
  end
  it "sets conditions with attribute writers" do 
      search = User.search
                ::Object.send(:binding).pry
      
      search.name_contains = "James"
      search.age_lt = 21
      search.username_eq = "jvans1"

      james = search.all 
      james.count.should eq(1)
      name = james.map(&:name)
      name.should eq(["James"])
  end

  xit "overrides conditions with attribute writers" do 


  end

  xit "has readers for conditions" do


  end



end