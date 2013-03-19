require 'spec_helper'

describe Searchlogic::ScopeReflectionExt::ScopeLambda do 
  context "#scope_lambda" do 
    it "returns the scope lambda associated with named scope" do 
      $the_scope = lambda{}
      class User; scope :user_scope, $the_scope;end
      Searchlogic::ScopeReflection.new(:user_scope, User).scope_lambda.should eq($the_scope)      
      $the_scope = nil
    end
    it "returns nil if the method is not a named scope" do 
      Searchlogic::ScopeReflection.new(:not_a_scope, User).scope_lambda.should be_nil      
    end
  end
  context "#scope_lambda_type" do 
    it "returns the type of the scope lambda" do 
      class User; scope :user_scope, lambda{}; named_scopes[:user_scope][:type] = :boolean;end
      Searchlogic::ScopeReflection.new(:user_scope, User).scope_lambda_type.should eq(:boolean)
    end

    it "returns nil if the condition is not a scope lambda" do 
      Searchlogic::ScopeReflection.new(:not_a_scope, User).scope_lambda_type.should be_nil
    end
  end
end