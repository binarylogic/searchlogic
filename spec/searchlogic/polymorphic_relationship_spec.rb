require 'spec_helper'

describe Searchlogic::Conditions::Polymorphic do 
  before(:each) do 
    @a1 = Audit.create(:name => "James' Audit")
    @a2 = Audit.create(:name => "Ben's Audit")
    @james = User.create(:name => "James", :audits => [@a1])
    @ben = User.create(:name=>"Ben", :audits => [@a2])

  end

  it "finds all other users besides partial name" do 
    audits = Audit.auditable_user_type_name_equals("James")
    audits.count.should eq(1)
    names = audits.map(&:name)
    names.first.should eq("James' Audit")
  end
  
end