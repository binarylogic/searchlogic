require 'spec_helper'

describe Searchlogic::ScopeReflection do 

  context "#initialize" do 
    it "initializes with a klass and a method" do 
      expect{Searchlogic::ScopeReflection.new(:name_equal, User)}.to_not raise_error
    end

    it "should raise an Error if the class doesn't exist" do 
      expect{Searchlogic::ScopeReflection.new(:name_equal, Usser)}.to raise_error
    end
  end

  context "#column?" do 
    it "should return true if it's a column of the class" do 
      Searchlogic::ScopeReflection.new(:users_count, Company).column?.should be_true
    end

    it "should raise an error if ScopeReflection was not initialized with a class" do 
      expect{Searchlogic::ScopeReflection.new(:users_count).column?}.to raise_error Searchlogic::ScopeReflectionExt::UninitializedClassError

    end
  end
  context "#scope?" do 
    it "should return true if it's a scope of the class" do 
      class Company; scope :company_scope, lambda{};end
      Searchlogic::ScopeReflection.new(:company_scope, Company).scope?.should be_true
    end

    it "should return false if it's a scope of another class" do 
      class User; scope :user_scope, lambda{};end
      Searchlogic::ScopeReflection.new(:user_scope, Company).scope?.should be_false
    end

    it "should raise an error if ScopeReflection was not initialized with a class" do 
      class User; scope :user_scope, lambda{};end

      expect{Searchlogic::ScopeReflection.new(:users_count).scope?}.to raise_error Searchlogic::ScopeReflectionExt::UninitializedClassError

    end    
  end
end