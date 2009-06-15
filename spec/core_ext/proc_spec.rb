require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe "Proc" do
  it "should have a searchlogic_arg_type accessor" do
    p = Proc.new {}
    p.searchlogic_arg_type = :integer
    p.searchlogic_arg_type.should == :integer
  end
end
