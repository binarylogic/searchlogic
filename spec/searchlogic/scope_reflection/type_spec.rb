require 'spec_helper'

describe Searchlogic::ScopeReflectionExt::Type do 

  context "#name" do 
    it "takes a method and returns the column name" do 
      scope_refl = Searchlogic::ScopeReflection.new( :created_at_greater_than_or_equal_to,User)
      scope_refl.name.should eq("created_at")
    end

    it "should not match similar methods" do 
      scope_refl = Searchlogic::ScopeReflection.new( :username_less_than_or_equal_to,User)
      scope_refl.name.should eq("username")
    end 
  end

  
  context "#type" do 
    it "takes a method and returns the column type" do 
      scope_refl = Searchlogic::ScopeReflection.new( :created_at_greater_than_or_equal_to,User)
      scope_refl.type.should eq(:datetime)
    end
    it "finds column types on associated columns" do 
      scope_refl = Searchlogic::ScopeReflection.new(:users_orders_line_items_price_greater_than_or_equal_to, Company)
      scope_refl.type.should eq(:float)
    end

    it "returns value of 'unspecified' for scopes w/out an explicit set" do 
      class User; scope :working_age, lambda{ |age| where( name_eq(age)) };end
      scope_refl = Searchlogic::ScopeReflection.new( :working_age,User)
      scope_refl.type.should eq(:unspecified)
    end

    it "allows you to specify a type of variable" do 
      class User; scope :cool, lambda{|date| where("created_at > ?", date)};end
      User.named_scopes[:cool][:type] = :datetime
      User.named_scopes[:cool][:type].should eq(:datetime)
      scope_refl = Searchlogic::ScopeReflection.new( :cool,User)
      scope_refl.type.should eq(:datetime)
    end

    it "allows you to assign multiple types" do
      class User; scope :fun, lambda{|date, age, name| where("created_at > ?", date)};end
      User.named_scopes[:fun][:type] = [:datetime, :age, :name]
      User.named_scopes[:fun][:type].should eq([:datetime, :age, :name])
      scope_refl = Searchlogic::ScopeReflection.new( :fun,User)
      scope_refl.type.should eq([:datetime, :age, :name])
    end

    it "knows to assign null/nil/blank/present to boolean" do 
      scope_refl = Searchlogic::ScopeReflection.new( :username_null,User)
      scope_refl.type.should eq(:boolean)
      scope_refl = Searchlogic::ScopeReflection.new( :username_nil,User)
      scope_refl.type.should eq(:boolean)
      scope_refl = Searchlogic::ScopeReflection.new( :username_blank,User)
      scope_refl.type.should eq(:boolean)
      scope_refl = Searchlogic::ScopeReflection.new( :username_present,User)
      scope_refl.type.should eq(:boolean)
    end

    it "should assign scopes of arity = 0 to boolean"  do
      class User; scope :old, lambda{ where(age_eq(40)) };end
      scope_refl = Searchlogic::ScopeReflection.new( :old,User)
      scope_refl.type.should eq(:boolean)
    end

    it "should raise an error if not a recognized scope, association, or column" do 
      scope_refl = Searchlogic::ScopeReflection.new( :boogie,User)
      expect{scope_refl.type}.to raise_error(NoMethodError)
    end
  end
end