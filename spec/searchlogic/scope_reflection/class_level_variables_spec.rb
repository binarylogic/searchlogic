require 'spec_helper'

describe Searchlogic::ScopeReflectionExt::ClassLevelVariables do 

  context ".scope_reflection" do
    it "keeps track of named scopes created" do 
      class User; scope :winner, lambda{ where("age > ?", 26)};end
      Searchlogic::ScopeReflection.defined_named_scopes.should_not be_empty
    end
    it "keeps track in a hash with name of scope as key and value as an array with class and proc" do
      @@proc = Proc.new do  User.where("age > ?", 26) end
      class User; scope :winner, @@proc;end
      Searchlogic::ScopeReflection.defined_named_scopes.should eq({:winner => [User, @@proc ]})
    end
  end
end