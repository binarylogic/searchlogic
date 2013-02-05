require 'spec_helper'

describe Searchlogic::Conditions::DoesNotEqual do 
  before(:each) do 
    @james = User.new
    @james.name = "James"
    @james.save
    @bob = User.new
    @bob.name = "Bob"
    @bob.save 
  end
  it "finds users that do not equal input" do 
    find_bob = User.name_does_not_equal("James").first
    find_bob.name.should eq("Bob")
  end
end