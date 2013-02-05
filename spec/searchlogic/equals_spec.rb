require 'spec_helper'

describe Searchlogic::Conditions::Equals do
  it "return the user from .column_equals"  do 
    james = User.new
    james.name = "James"
    james.save
    User.name_equals("James").should_not be_empty
  end
end