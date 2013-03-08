require 'spec_helper'

describe Searchlogic::SearchExt::Methods do 
  context "#delete" do
    it "should delete the condition" do
      search.delete("username_like")
      search.username_like.should be_nil
      search.conditions["username_like"].should be_nil
    end
  end  
  context "#to_params" do 
    it "should convert the conditions to a query string" do 
      search = User.search(:username_like => "jvans1", :age_gte_or_id_eq => 20, :created_at_before => "yesterday")
      binding.pry
    end

  end
end