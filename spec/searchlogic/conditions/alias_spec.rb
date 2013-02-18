require 'spec_helper'

describe Searchlogic::Conditions::Aliases do 
  before(:each) do 
    @james = User.create(:name=>"James", :age => 26, :company_id => 34)
    User.create(:name=>"Jon", :email => "jon@James.com", :company_id => 4)
    User.create(:name=>"aJJ", :username => "James", :company_id => 12)
    @ben = User.create(:name=>"Ben", :age => 28, :username => "JamesVanneman", :company_id => 15)
    @tren = User.create(:name=>"Tren", :age =>45)
  end

  describe "works with OR conditionals" do 
    it "with two of the same conditionals" do 
      users = User.name_eq_or_username_eq("James")
      users.count.should eq(2)
      names = users.map(&:name)
      names.should eq(["James", "aJJ"])
    end
    it "when first conditional is omitted" do 
      users = User.name_or_username_eq("James")
      users.count.should eq(2)
      names = users.map(&:name)
      names.should eq(["James", "aJJ"])

    end
    it "with two different conditionals" do 
      users = User.name_eq_or_email_contains("James")
      users.count.should eq(2)
      names = users.map(&:name)
      names.should eq(["James", "Jon"])
    end
    it "with three different conditionals" do 
      users = User.name_eq_or_email_contains_or_username_bw("James")
      users.count.should eq(4)
      names = users.map(&:name)
      names.should eq(["James", "Jon","aJJ", "Ben"])
    end

    it "with multiple inequalities" do 
      users = User.age_or_company_id_gte(28)
      users.count.should eq(3)
      names = users.map(&:name)
      names.should eq(["Ben", "Tren", "James"])
    end
  end
  describe "map to correct value" do
    it "is == equals" do 
      users = User.name_is("James")
      users.count.should eq(1)
      names = users.map(&:name)
      names.should eq(["James"])
    end

    it "lt == less_than" do 
      users = User.age_lt(28)
      users.count.should eq(1)
      names = users.map(&:name)
      names.should eq(["James"])
    end

    it "before == less_than" do 
      users = User.age_before(28)
      users.count.should eq(1)
      names = users.map(&:name)
      names.should eq(["James"])
    end

    it "lte == less_than_or_equal_to" do 
      users = User.age_lte(28)
      users.count.should eq(2)
      names = users.map(&:name)
      names.should eq(["James", "Ben"])
    end
    it "gt and after == greater_than" do 
      gt_users = User.age_gt(28)
      after_users = User.age_after(28)
      gt_users.count.should eq(1)
      after_users.count.should eq(1)
      gt_users.first.name.should eq("Tren")
      after_users.first.name.should eq("Tren")
    end

    it "does_not_include == not_like" do 
      dni = User.name_does_not_include("e")
      dni.count.should eq(2)
      names = dni.map(&:name)
      names.should eq(["Jon", "aJJ"])
    end

    it " not_begin_with == does_not_begine_with" do 
      nbw = User.name_not_begin_with("J")
      nbw.count.should eq(3)
      names = nbw.map(&:name)
      names.should eq(["aJJ", "Ben", "Tren"])
    end

    it "ew = ends_with" do 
      ew = User.name_ew("en")
      ew.count.should eq(2)
      names = ew.map(&:name)
      names.should eq(["Ben", "Tren"])
    end
    it "not_end with == does_not_end_with" do 
      nendw = User.name_not_end_with("en")
      nendw.count.should eq(3)
      names = nendw.map(&:name)
      names.should eq(["James", "Jon", "aJJ"])
    end
    it "nil == null" do 
      nil_ages = User.age_nil
      nil_ages.count.should eq(2)
      names = nil_ages.map(&:name)
      names.should eq(["Jon", "aJJ"])
    end
    it "bw == beginswith" do
      begins_j = User.name_bw("J")
      begins_j.map(&:name).should eq(["James", "Jon"])
    end
  end
end