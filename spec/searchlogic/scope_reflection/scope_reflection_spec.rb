require 'spec_helper'

describe Searchlogic::ScopeReflection do 

  context "#initialize" do 
    it "initializes with a klass and a method" do 
      expect{Searchlogic::ScopeReflection.new(:name_equal, User)}.to_not raise_error
    end

    it "should raise an Error if the class doesn't exist" do 
      expect{Searchlogic::ScopeReflection.new(:name_equal, User)}.to raise_error
    end
  end

end