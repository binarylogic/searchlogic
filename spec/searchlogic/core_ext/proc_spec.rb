require 'spec_helper'

describe Searchlogic::CoreExt::Proc do
  it "should have a searchlogic_options accessor" do
    p = Proc.new {}
    p.searchlogic_options[:type] = :integer
  end
end
