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
end