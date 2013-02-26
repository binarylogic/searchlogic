require 'spec_helper'

describe Searchlogic::SearchExt::Delete do 
  context "#delete" do
    it "should delete the condition" do
      search = User.search(:username_like => "bjohnson")
      search.delete("username_like")
      search.username_like.should be_nil
      search.conditions["username_like"].should be_nil
    end
  end  
end