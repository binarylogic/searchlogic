require 'spec_helper'
describe Searchlogic::ActiveRecordExt::Scopes::Conditions::MethodConstructor do
  context ".create_methods_array" do 
    it "should add an ending alias to a method without on" do 
      Searchlogic::ActiveRecordExt::Scopes::Conditions::MethodConstructor.new(:name_or_username_like).methods_array .should eq(["name_like", "username_like"])
    end


    it "should add alias problerly with all" do 
       Searchlogic::ActiveRecordExt::Scopes::Conditions::MethodConstructor.new(:name_or_username_like_all).methods_array.should eq(["name_like_all", "username_like_all" ])
    end
    it "won't return the method if it's the same as the end of a scope" do 
      class User; scope :u_name, lambda{};end
      Searchlogic::ActiveRecordExt::Scopes::Conditions::MethodConstructor.new(:name_or_username_like).methods_array .should eq(["name_like", "username_like"])
    end

    it "works with _or_equal_to_all" do 
      Searchlogic::ActiveRecordExt::Scopes::Conditions::MethodConstructor.new(:username_like_or_name_like_all).methods_array.should eq(["username_like_all", "name_like_all"])
    end

  end 
end