require 'spec_helper'

describe Searchlogic::ActiveRecordExt::Scopes::Conditions::NamedScopeArity do 



  it "returns the arity of the given scope" do 

    User.named_scope_arity("name_null").should eq(0)
  end


end