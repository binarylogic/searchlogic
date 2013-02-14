require 'spec_helper'

describe Searchlogic::Conditions::Polymorphic do 
  before(:each) do 
    Company.create(:name => "Concierge Live", :audits => [Audit.create()])
    @a1 = Audit.create(:name => "James' Audit")
    @a2 = Audit.create(:name => "Ben's Audit")
    @james = User.create(:name => "James", :audits => [@a1])
    @ben = User.create(:name=>"Ben", :audits => [@a2])

  end

  it "finds all of the associations with a Polymorphic type" do 
    audits = Audit.auditable_user_type_name_equals("James")
    audits.count.should eq(1)
    names = audits.map(&:name)
    names.first.should eq("James' Audit")
  end

  it "find the associations from other side of Polymorphic relationship" do 
    user = User.audits__name_equals("James' Audit")
    user.count.should eq(1)
    name = user.map(&:name).first
    name.should eq("James")
  end

end