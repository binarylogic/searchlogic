require 'spec_helper'

describe Searchlogic::CoreExt::Object do
  it "should accept and pass the argument to the searchlogic_options" do
    proc = searchlogic_lambda(:integer, :test => :value) {}
    proc.searchlogic_options[:type].should == :integer
    proc.searchlogic_options[:test].should == :value
  end
end
