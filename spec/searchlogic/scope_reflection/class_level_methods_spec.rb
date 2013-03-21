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
  context ".authorized?" do 
    it "should return true for aliases" do 
      Searchlogic::ScopeReflection.authorized?(:name_lte).should be_true
    end

    it "should return true for named scopes" do 
      class User; scope :this_one, lambda{};end
      Searchlogic::ScopeReflection.authorized?(:name_this_one).should be_true
    end

    it "should return true for searchlogic defined scopes" do 
      Searchlogic::ScopeReflection.authorized?(:name_equals).should be_true
    end

    it "should return false for unrecobnized scopes" do 
      Searchlogic::ScopeReflection.authorized?(:name_eqquals).should be_false
    end

    it "shoudl return false for column names" do 
      Searchlogic::ScopeReflection.authorized?(:name).should be_false

    end

  end
end