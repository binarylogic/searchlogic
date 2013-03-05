require 'spec_helper'

describe Searchlogic::ScopeReflectionExt::ClassLevelMethods do 

  context ".scope_reflection" do
    it "keeps track of named scopes created" do 
      class User; scope :winner, lambda{ where("age > ?", 26)};end
      User.named_scopes[:winner][:type].should_not be_empty
    end

    it "keeps tracks in a hash with name of scope as key and value as type of arg defaulting to :unspecified" do
      class User; scope :winner, lambda{ |age| where("age > ?", 26)};end
      User.named_scopes[:winner][:type].should eq(:unspecified)
    end

  end
end