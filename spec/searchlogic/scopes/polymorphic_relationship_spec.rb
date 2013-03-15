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

  it "returns an AR relation" do 
    user = Audit.auditable_user_type_id_gte(23)
    user.should be_kind_of ActiveRecord::Relation
  end

  it " works with associations off of polymorph relationship" do 
    user = Audit.auditable_user_type_name_eq("James")
    user.should eq([@a1])
  end

  context "#new_method" do 
    it "returns the method that follows the specified Polymorphic association type" do 
      pmr = Searchlogic::ActiveRecordExt::Scopes::Conditions::Polymorphic.new(User, :auditable_user_type_orders_total_gte, [])
      pmr.method_on_association.should eq("orders_total_gte")
    end
  end

  context "search" do 
    it "works in a search proxy" do 
      search = User.search(:audits_name_eq => "James' Audit")
      search.all.should eq([@u2])
    end

    it "works with a associations in a search proxy" do 
      search = User.search(:audits_name_eq => "James' Audit")
      search.all.should eq([@u2])

    end
    it "works with lots of conditions " do 
      search = User.search(:name_equals => "James", :age_greater_than_or_equal_to => 20, :id_eq_or_orders_total_greater_than_or_equal_to => 5, :audits_name_like => "ames", :order =>:descend_by_orders_line_items_price)
      expect{search.all}.to_not raise_error
      
    end
    
    it "works from other direction in search proxy" do 
      search = User.search(:audits_name_eq => "James' Audit")
      search.all.should eq([@u2])
    end
  end
end