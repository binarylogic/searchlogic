require 'spec_helper'
describe Searchlogic::ActiveRecordExt::Scopes::Conditions::Condition do 
  context ".matchers" do 
    it "returns an array of all matchers for conditions" do 
      ActiveRecord::Base.all_matchers.should be_kind_of(Array)
    end
  end
end