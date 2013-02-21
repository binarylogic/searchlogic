require 'spec_helper'

describe Searchlogic::Search::Ordering do 
  before(:each) do 
    User.create(:name=>"James", :age =>20, :username => "jvans1" )
    @sarah = User.create(:name=>"Sarah", :age =>22, :username => "jvans1")
    @john = User.create(:name=>"John", :age =>26, :username => "jvans1")
    @jason = User.create(:name=>"Jason", :age =>31, :username => "jvans1")
    User.create(:name => "Tren")
    User.create(:name=>"Ben")
  end

  it "ascend's by" do
    search = User.searchlogic(:ascend_by => "id")
    people = search.all
    people.count.should eq(6)
    people.map(&:id).should eq([1, 2, 3, 4, 5, 6])
  end
  it "descend's by" do
    search = User.searchlogic(:descend_by => "id")
    people = search.all
    people.count.should eq(6)
    people.map(&:id).should eq([6, 5, 4, 3, 2, 1])
  end
  it "ordering containing other conditions" do 
    search = User.searchlogic(:descend_by => "id", :username_eq => "jvans1", :age_gt => 21)
    users = search.all
    users.map(&:id).should eq([@jason.id, @john.id, @sarah.id])
  end
end
