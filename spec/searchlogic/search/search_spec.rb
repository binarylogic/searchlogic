require 'spec_helper'

describe Searchlogic::Search::SearchProxy::Base do 
  before(:each) do 
    @james = User.create(:name=>"James")
    @ben = User.create(:name=>"Ben")
    @john = User.create(:name=>"John")
    @tren = User.create(:name=>"Tren")
    @noorder = User.create(:name=>"noorder")
  end

  describe "Proxy Object" do 
    it "has reader" do
      search = User.search(:name_like => "James")
      binding.pry
      search.name_like = "James"
      search.method.should eq(name_like("James"))
    end
  end
end