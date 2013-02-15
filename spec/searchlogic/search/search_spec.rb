require 'spec_helper'

describe Searchlogic::Search::Base::Base do 
  before(:each) do 
    @james = User.create(:name=>"James")
    @ben = User.create(:name=>"Ben")
    @john = User.create(:name=>"John")
    @tren = User.create(:name=>"Tren")
    @noorder = User.create(:name=>"noorder")


  end
  it "creates a chainable proxy object" do
    User.search(:name_like => "James")

  end

end