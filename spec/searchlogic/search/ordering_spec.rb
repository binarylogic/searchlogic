require 'spec_helper'

describe Searchlogic::Search::SearchProxy::Ordering do 
  before(:each) do 
    User.create(:name=>"James", :age =>20, :username => "jvans1" )
    User.create(:name=>"Sarah", :age =>22, :username => "jvans1")
    User.create(:name=>"John", :age =>26, :username => "jvans1")
    User.create(:name=>"Jason", :age =>31, :username => "jvans1")
    User.create(:name => "Tren")
    User.create(:name=>"Ben")
  end

  it "ascend's by" do
    search = User.search(:ascend_by => "id")
    people = search.all
    people.count.should eq(6)
    people.map(&:name).should eq(["James", "Sarah", "John", "Jason", "Tren", "Ben"])
  end
  it "descend's by" do
    search = User.search(:descend_by => "id")
    people = search.all
    people.count.should eq(6)
    people.map(&:name).should eq(["James", "Sarah", "John", "Jason", "Tren", "Ben"].reverse)
  end
  it "ordering containing other conditions" do 
    search = User.search(:descend_by => "id", :username_eq => "jvans1", :age_gt => 21)
    users = search.all
    users.map(&:name).should eq(["Jason", "John", "Sarah"])
  end
end
