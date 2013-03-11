require 'spec_helper'

describe Searchlogic::ActiveRecordExt::Scopes::Conditions::Polymorphic do 
  before(:each) do 
    a1 = Audit.create(:name => "James' Audit")
    @a2 = Audit.create(:name => "Ben's Audit")
    a3 = Audit.create(:name => "Company's Audit")
    User.create(:name => "James", :audits => [a1], :orders => [Order.create(:total => 25), Order.create(:total => 19)])
    u1 = User.create(:name=>"Ben", :audits => [@a2], :orders => [Order.create(:total => 23), Order.create(:total => 18)])
    Company.create(:audits => [a3], :users=> [u1] )
  end

  it "finds all of the associations with a Polymorphic type" do 
    Audit.auditable_user_type_orders_ascend_by_total.should_not  include(a3)
  end

  it "find the associations from other side of Polymorphic relationship" do 
    user = User.audits__name_equals("James' Audit")
    user.count.should eq(1)
    name = user.map(&:name).first
    name.should eq("James")
  end

  it "returns an AR relation" do 
    audits = Audit.auditable_user_type_orders_total_gte(23)
    audits.should be_kind_of ActiveRecord::Relation
  end

  context "search" do 
    it "works in a search proxy" do 
      search = Audit.search(:auditable_user_type_orders_total_gte => 23, :name_like => "en")
      search.all.should eq(@a2)
    end
    xit "works from other direction in search proxy" do 
    end
  end
end