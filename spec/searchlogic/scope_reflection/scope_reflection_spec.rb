require 'spec_helper'

describe Searchlogic::ScopeReflection do 

  context "#initialize" do 
    it "initializes with a klass and a method" do 
      expect{Searchlogic::ScopeReflection.new(User, :name_equal)}.to_not raise_error
    end
  end

end