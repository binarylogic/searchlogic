require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe "Conditions" do
  it "should be dynamically created and then cached" do
    User.should_not respond_to(:age_less_than)
    User.age_less_than(5)
    User.should respond_to(:age_less_than)
  end
  
  context "comparison conditions" do
    it "should have equals" do
      (5..7).each { |age| User.create(:age => age) }
      User.age_equals(6).all.should == User.find_all_by_age(6)
    end
    
    it "should have less than" do
      (5..7).each { |age| User.create(:age => age) }
      User.age_less_than(6).all.should == User.find_all_by_age(5)
    end
    
    it "should have less than or equal to" do
      (5..7).each { |age| User.create(:age => age) }
      User.age_less_than_or_equal_to(6).all.should == User.find_all_by_age([5, 6])
    end
    
    it "should have greater than" do
      (5..7).each { |age| User.create(:age => age) }
      User.age_greater_than(6).all.should == User.find_all_by_age(7)
    end
    
    it "should have greater than or equal to" do
      (5..7).each { |age| User.create(:age => age) }
      User.age_greater_than_or_equal_to(6).all.should == User.find_all_by_age([6, 7])
    end
  end
  
  context "wildcard conditions" do
    it "should have like" do
      %w(bjohnson thunt).each { |username| User.create(:username => username) }
      User.username_like("john").all.should == User.find_all_by_username("bjohnson")
    end
    
    it "should have begins with" do
      %w(bjohnson thunt).each { |username| User.create(:username => username) }
      User.username_begins_with("bj").all.should == User.find_all_by_username("bjohnson")
    end
    
    it "should have ends with" do
      %w(bjohnson thunt).each { |username| User.create(:username => username) }
      User.username_ends_with("son").all.should == User.find_all_by_username("bjohnson")
    end
  end
  
  context "boolean conditions" do
    it "should have null" do
      ["bjohnson", nil].each { |username| User.create(:username => username) }
      User.username_null.all.should == User.find_all_by_username(nil)
    end
    
    it "should have empty" do
      ["bjohnson", ""].each { |username| User.create(:username => username) }
      User.username_empty.all.should == User.find_all_by_username("")
    end
  end
  
  context "alias conditions" do
    it "should have is" do
      User.age_is(5).proxy_options.should == User.age_equals(5).proxy_options
    end
    
    it "should have eq" do
      User.age_eq(5).proxy_options.should == User.age_equals(5).proxy_options
    end
    
    it "should have not_equal_to" do
      User.age_not_equal_to(5).proxy_options.should == User.age_does_not_equal(5).proxy_options
    end
    
    it "should have is_not" do
      # This is matching "not" first. How do you give priority in a regex? Because it's matching the
      # 'not' condition and thinking the column is 'age_is'.
      pending
      User.age_is_not(5).proxy_options.should == User.age_does_not_equal(5).proxy_options
    end
    
    it "should have not" do
      User.age_not(5).proxy_options.should == User.age_does_not_equal(5).proxy_options
    end
    
    it "should have ne" do
      User.age_ne(5).proxy_options.should == User.age_does_not_equal(5).proxy_options
    end
    
    it "should have lt" do
      User.age_lt(5).proxy_options.should == User.age_less_than(5).proxy_options
    end
    
    it "should have lte" do
      User.age_lte(5).proxy_options.should == User.age_less_than_or_equal_to(5).proxy_options
    end
    
    it "should have gt" do
      User.age_gt(5).proxy_options.should == User.age_greater_than(5).proxy_options
    end
    
    it "should have gte" do
      User.age_gte(5).proxy_options.should == User.age_greater_than_or_equal_to(5).proxy_options
    end
    
    it "should have contains" do
      User.username_contains(5).proxy_options.should == User.username_like(5).proxy_options
    end
    
    it "should have contains" do
      User.username_includes(5).proxy_options.should == User.username_like(5).proxy_options
    end
    
    it "should have bw" do
      User.username_bw(5).proxy_options.should == User.username_begins_with(5).proxy_options
    end
    
    it "should have ew" do
      User.username_ew(5).proxy_options.should == User.username_ends_with(5).proxy_options
    end
    
    it "should have nil" do
      User.username_nil.proxy_options.should == User.username_nil.proxy_options
    end
  end
  
  context "searchlogic lambda" do
    it "should be a string" do
      User.username_like("test")
      User.named_scope_options(:username_like).searchlogic_arg_type.should == :string
    end
    
    it "should be an integer" do
      User.id_gt(10)
      User.named_scope_options(:id_gt).searchlogic_arg_type.should == :integer
    end
    
    it "should be a float" do
      Order.total_gt(10)
      Order.named_scope_options(:total_gt).searchlogic_arg_type.should == :float
    end
  end
end
