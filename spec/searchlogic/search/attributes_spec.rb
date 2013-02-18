require 'spec_helper'

describe Searchlogic::Search::SearchProxy::Attributes do 
  it "defaults conditions to an emtpy hash" do 

    search = User.search
    search.conditions.should eq({})
  end
end