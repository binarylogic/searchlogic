require 'spec_helper'

describe Searchlogic::ActiveRecordExt::Scopes::Conditions::Polymorphic do 
  before(:each) do 
    a1 = Audit.create(:name => "James' Audit")
    a2 = Audit.create(:name => "Ben's Audit")
    User.create(:name => "James", :audits => [a1], :orders => [Order.create(:total => 25), Order.create(:total => 19)])
    User.create(:name=>"Ben", :audits => [a2], :orders => [Order.create(:total => 23), Order.create(:total => 18)])

  end

  it "finds all of the associations with a Polymorphic type" do 
    audits = Audit.auditable_user_type_orders_ascend_by_total
    audits.count.should eq(4)
    names = audits.map(&:name)
    names.should eq(["Ben's Audit", "James' Audit", "Ben's Audit", "James' Audit"])
  end

  it "find the associations from other side of Polymorphic relationship" do 
    user = User.audits__name_equals("James' Audit")
    user.count.should eq(1)
    name = user.map(&:name).first
    name.should eq("James")
  end

end