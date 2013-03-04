require 'spec_helper'

describe Searchlogic::ScopeReflectionExt::Column do 


  context "#column_name" do 
    it "takes a method and returns the column name" do 
      scope_refl = Searchlogic::ScopeReflection.new(User, :created_at_greater_than_or_equal_to)
      scope_refl.column_name.should eq("created_at")
    end

    it "should match similar methods" do 
      scope_refl = Searchlogic::ScopeReflection.new(User, :username_less_than_or_equal_to)
      scope_refl.column_name.should eq("username")
    end
  end

  
  context "#column_type" do 
    it "takes a method and returns the column type" do 
      scope_refl = Searchlogic::ScopeReflection.new(User, :created_at_greater_than_or_equal_to)
      scope_refl.column_type.should eq(:datetime)
    end

    it "can be explicity set" do 
      scope_refl = Searchlogic::ScopeReflection.new(User, :name_gte)
      scope_refl.column_type.should eq(:string)
      scope_refl.column_type = :datetime
      scope_refl.column_type.should eq(:datetime)
    end
  end
end