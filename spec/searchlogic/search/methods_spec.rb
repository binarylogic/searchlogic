require 'spec_helper'

describe Searchlogic::SearchExt::Methods do 
  context "#delete" do
    it "should delete the condition" do

      search = User.search(:username_like => "James")
      search.conditions.keys.should include(:username_like)
      search.delete("username_like")
      search.username_like.should be_nil
      search.conditions["username_like"].should be_nil
    end
  end  
  
  context "#to_params" do 
    it "should convert the conditions to a query string" do 
      search = User.search(:username_like => "jvans1", :age_gte_or_id_eq => 20, :created_at_before => Date.new(2012,2,4))
      search.to_params.should eq("age_gte_or_id_eq&20&created_at_before&2012-02-04&username_like&jvans1")
    end

  end
end