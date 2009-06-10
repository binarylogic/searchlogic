require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe "Object" do
  it "should accept and pass the argument to the searchlogic_arg_type" do
    searchlogic_lambda(:integer) {}.searchlogic_arg_type.should == :integer
  end
end
