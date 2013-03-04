require 'spec_helper'

describe Searchlogic::ScopeReflectionExt::ClassLevelVariables do 

  context ".scope_reflection" do
    it "keeps track of named scopes created" do 
      class User; scope :winner, lambda{ where("age > ?", 26)};end
      Searchlogic::ScopeReflection.defined_named_scopes.should_not be_empty
    end
    it "keeps track in a hash with name of scope as key and value as type of arg defaulting to :unspecified" do
      class User; scope :winner, where("age > ?", 26);end
      Searchlogic::ScopeReflection.defined_named_scopes.should eq({:winner => :unspecified })
    end
    it "allows you to specify a type of variable" do 
      class User; scope :cool, lambda{|date| where("created_at > ?", date)};end
      Searchlogic::ScopeReflection.defined_named_scopes[:cool] = :datetime
      Searchlogic::ScopeReflection.defined_named_scopes[:cool].should eq(:datetime)
    end

    it "allows you to assign multiple types" do
      class User; scope :fun, lambda{|date, age, name| where("created_at > ?", date)};end
      Searchlogic::ScopeReflection.defined_named_scopes[:fun] = [:datetime, :age, :name]
      Searchlogic::ScopeReflection.defined_named_scopes[:fun].should eq([:datetime, :age, :name])
    end
    
  end
end