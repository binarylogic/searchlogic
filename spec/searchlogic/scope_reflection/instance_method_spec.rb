require 'spec_helper'

describe Searchlogic::ScopeReflectionExt::InstanceMethods do 
  context "#joined_named_scopes" do 
    it "should return nil if there are no named scopes" do 
      Searchlogic::ScopeReflection.new(:some_method).joined_named_scopes.should be_nil
    end

    it "should return a list of all named scopes for all classes" do       
      class User; scope :User_scope, lambda{}; end
      class Company; scope :Co_scope, lambda{}; end
      class LineItem; scope :L_I_Scope, lambda{}; end
      (Searchlogic::ScopeReflection.new(:some_method).joined_named_scopes).should eq("Co_scope|User_scope|L_I_Scope")
    end

  end
  context "#condition" do 
    it "returns the converted alias" do 
      Searchlogic::ScopeReflection.new(:name_eq, User).condition.should eq("name_equals")
    end

    it "doesn't change conditions that already match" do 
      Searchlogic::ScopeReflection.new(:name_equals, User).condition.should eq(:name_equals)
    end

    it "doesn't get confused with named scopes that match an alias" do 
      class User; scope :cool_name_eq, lambda{}; end
      Searchlogic::ScopeReflection.new(:cool_name_eq, User).condition.should eq(:cool_name_eq)
    end

    it "should not convert alias if it matches a named scope" do
      class User; scope :group_gt, lambda{|age| age_gt(age).created_at_after("yesterday")};end
      Searchlogic::ScopeReflection.new(:group_gt).condition.should eq(:group_gt)
    end

    it "does_not_end_with doesn't get matched by _ends_with" do 
      Searchlogic::ScopeReflection.new(:name_ends_with).condition.should eq(:name_ends_with)
    end
    it "does_not_end_with" do 
      Searchlogic::ScopeReflection.new(:name_does_not_end_with).condition.should eq(:name_does_not_end_with)
    end    
  end

  context "#predicate" do 
    it "returns the predicate on a condition" do 
      Searchlogic::ScopeReflection.new(:username_equals, User).predicate.should eq("_equals")
    end
    it "should raise unknown condition error if doesn't exist" do 
      expect{Searchlogic::ScopeReflection.new(:username_eqquals, User).predicate}.to raise_error Searchlogic::ActiveRecordExt::Scopes::InvalidConditionError
    end

    it "should include an any condition if present" do 
      Searchlogic::ScopeReflection.new(:username_equals_any, User).predicate.should eq("_equals_any")
    end
    it "should include an or condition if present" do 
      Searchlogic::ScopeReflection.new(:username_equals_all, User).predicate.should eq("_equals_all")
    end

    it "should return the alias if present" do 
      Searchlogic::ScopeReflection.new(:username_lte).predicate.should eq("_lte")
    end

  end

end