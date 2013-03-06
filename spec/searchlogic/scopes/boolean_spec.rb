require 'spec_helper'

describe "Searchlogic::ActiveRecordExt::Scopes::Conditions::Boolean" do 


  it "creates scopes on boolean columns" do 
    male = User.create(:male => true)
    female = User.create(:male => false)
    User.male.should eq([male])
  end

  it "should not create scope for non-boolean columns" do
    expect{User.age}.to raise_error
  end
end