require 'spec_helper'

describe Searchlogic::ActiveRecordExt::Scopes::Conditions::Polymorphic do 
  before(:each) do 
    @a1 = Audit.create(:name => "James' Audit")
    @a2 = Audit.create(:name => "Ben's Audit")
    @a3 = Audit.create(:name => "Company's Audit")
    @u2 = User.create(:name => "James", :audits => [@a1], :orders => [Order.create(:total => 25, :line_items => [LineItem.create(:price => 15), LineItem.create(:price => 20)]), Order.create(:total => 19)])
    @u1 = User.create(:name=>"Ben", :audits => [@a2], :orders => [Order.create(:total => 23), Order.create(:total => 18, :line_items => [LineItem.create(:price => 12)])])
    Company.create(:audits => [@a3], :users => [@u1] )
  end

  it "finds all of the associations with a Polymorphic type" do 
    Audit.auditable_user_type_orders_ascend_by_total.should_not  include(@a3)
  end

  it "find the associations from other side of Polymorphic relationship" do 
    user = User.audits__name_equals("James' Audit")
    user.count.should eq(1)
    name = user.map(&:name).first
    name.should eq("James")
  end

  xit "returns an AR relation" do 
    audits = Audit.auditable_user_type_orders_total_gte(23)
    audits.should be_kind_of ActiveRecord::Relation
  end

  context "#new_method" do 
    it "returns the method that follows the specified Polymorphic association type" do 
      pmr = Searchlogic::ActiveRecordExt::Scopes::Conditions::Polymorphic.new(User, :auditable_user_type_orders_total_gte, [])
      pmr.new_method.should eq("orders_total_gte")
    end
  end

  context "search" do 
    xit "works in a search proxy" do 
      search = User.search(:audits_name => "James' Audit")
      search.all.should eq([@a2])
    end

    xit "works with a associations in a search proxy" do 
      search = User.search(:audits_name => "James' Audit")
      search.all.should eq([@u2])

    end
    
    it "works from other direction in search proxy" do 
      search = User.search(:audits_name_eq => "James' Audit")
      search.all.should eq([@u2])
    end
  end
end