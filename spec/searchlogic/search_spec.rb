require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe Searchlogic::Search do
  describe "Implementation" do
    context "#searchlogic" do
      it "should create a search proxy" do
        User.search(:username => "joe").should be_kind_of(Searchlogic::Search)
      end

      it "should create a search proxy using the same class" do
        User.search.klass.should == User
      end

      it "should pass on the current scope to the proxy" do
        company = Company.create
        user = company.users.create
        search = company.users.search
        search.current_scope.should == company.users.scope(:find)
      end
    end
  end

  context "#initialize" do
    it "should require a class" do
      lambda { Searchlogic::Search.new }.should raise_error(ArgumentError)
    end

    it "should set the conditions" do
      search = User.search(:username => "bjohnson")
      search.conditions.should == {:username => "bjohnson"}
    end
  end

  context "#clone" do
    it "should clone properly" do
      company = Company.create
      user1 = company.users.create(:age => 5)
      user2 = company.users.create(:age => 25)
      search1 = company.users.search(:age_gt => 10)
      search2 = search1.clone
      search2.age_gt = 1
      search2.all.should == User.all
      search1.all.should == [user2]
    end

    it "should clone properly without scope" do
      user1 = User.create(:age => 5)
      user2 = User.create(:age => 25)
      search1 = User.search(:age_gt => 10)
      search2 = search1.clone
      search2.age_gt = 1
      search2.all.should == User.all
      search1.all.should == [user2]
    end
  end

  context "#conditions" do
    it "should set the conditions and be accessible individually" do
      search = User.search
      search.conditions = {:username => "bjohnson"}
      search.username.should == "bjohnson"
    end

    it "should set the conditions and allow string keys" do
      search = User.search
      search.conditions = {"username" => "bjohnson"}
      search.username.should == "bjohnson"
    end

    it "should use custom scopes before normalizing" do
      User.create(:username => "bjohnson")
      User.named_scope :username, lambda { |value| {:conditions => {:username => value.reverse}} }
      search1 = User.search(:username => "bjohnson")
      search2 = User.search(:username => "nosnhojb")
      search1.count.should == 0
      search2.count.should == 1
    end

    # We ignore them upon execution. But we still want to accept the condition so that returning the conditions
    # preserves the values.
    it "should ignore blank values but still return on conditions" do
      search = User.search
      search.conditions = {"username" => ""}
      search.username.should be_nil
      search.conditions.should == {:username => ""}
    end

    it "should not ignore blank values and should not cast them" do
      search = User.search
      search.conditions = {"id_equals" => ""}
      search.id_equals.should be_nil
      search.conditions.should == {:id_equals => ""}
    end

    it "should ignore blank values in arrays" do
      search = User.search
      search.conditions = {"username_equals_any" => [""]}
      search.username_equals_any.should be_nil

      search.conditions = {"id_equals_any" => ["", "1"]}
      search.id_equals_any.should == [1]
    end
  end

  context "#compact_conditions" do
    it "should remove conditions with blank values" do
      search = User.search
      search.conditions = {"id_equals" => "", "name_equals" => "Ben"}
      search.compact_conditions.should == {:name_equals => "Ben"}
    end
  end

  context "condition accessors" do
    it "should allow setting exact columns individually" do
      search = User.search
      search.username = "bjohnson"
      search.username.should == "bjohnson"
    end

    it "should allow setting local column conditions individually" do
      search = User.search
      search.username_gt = "bjohnson"
      search.username_gt.should == "bjohnson"
    end

    it "should allow chaining conditions" do
      user = User.create(:username => "bjohnson", :age => 20)
      User.create(:username => "bjohnson", :age => 5)
      search = User.search
      search.username_equals("bjohnson").age_gt(10)
      search.all.should == [user]
    end

    it "should allow setting association conditions" do
      search = User.search
      search.orders_total_gt = 10
      search.orders_total_gt.should == 10
    end

    it "should allow setting pre-existing association conditions" do
      User.named_scope :uname, lambda { |value| {:conditions => ["users.username = ?", value]} }
      search = Company.search
      search.users_uname = "bjohnson"
      search.users_uname.should == "bjohnson"
    end

    it "should allow setting pre-existing association alias conditions" do
      User.alias_scope :username_has, lambda { |value| User.username_like(value) }
      search = Company.search
      search.users_username_has = "bjohnson"
      search.users_username_has.should == "bjohnson"
    end

    it "should allow using custom conditions" do
      User.named_scope(:four_year_olds, { :conditions => { :age => 4 } })
      search = User.search
      search.four_year_olds = true
      search.four_year_olds.should == true
      search.proxy_options.should == User.four_year_olds.proxy_options
    end

    it "should not merge conflicting conditions into one value" do
      # This class should JUST be a proxy. It should not do anything more than that.
      # A user would be allowed to call both named scopes if they wanted.
      search = User.search
      search.username_greater_than = "bjohnson1"
      search.username_gt = "bjohnson2"
      search.username_greater_than.should == "bjohnson1"
      search.username_gt.should == "bjohnson2"
    end

    it "should allow setting custom conditions individually with an arity of 0" do
      User.named_scope(:four_year_olds, :conditions => {:age => 4})
      search = User.search
      search.four_year_olds = true
      search.four_year_olds.should == true
    end

    it "should allow setting custom conditions individually with an arity of 1" do
      User.named_scope(:username_should_be, lambda { |u| {:conditions => {:username => u}} })
      search = User.search
      search.username_should_be = "bjohnson"
      search.username_should_be.should == "bjohnson"
    end

    it "should not allow setting conditions that are not scopes" do
      search = User.search
      lambda { search.unknown = true }.should raise_error(Searchlogic::Search::UnknownConditionError)
    end

    it "should not allow setting conditions on sensitive methods" do
      search = User.search
      lambda { search.destroy = true }.should raise_error(Searchlogic::Search::UnknownConditionError)
    end

    it "should not use the ruby implementation of the id method" do
      search = User.search
      search.id.should be_nil
    end

    context "type casting" do
      it "should be a Boolean given true" do
        search = User.search
        search.id_nil = true
        search.id_nil.should == true
      end

      it "should be a Boolean given 'true'" do
        search = User.search
        search.id_nil = "true"
        search.id_nil.should == true
      end

      it "should be a Boolean given '1'" do
        search = User.search
        search.id_nil = "1"
        search.id_nil.should == true
      end

      it "should be a Boolean given false" do
        search = User.search
        search.id_nil = false
        search.id_nil.should == false
      end

      it "should be a Boolean given 'false'" do
        search = User.search
        search.id_nil = "false"
        search.id_nil.should == false
      end

      it "should be a Boolean given '0'" do
        search = User.search
        search.id_nil = "0"
        search.id_nil.should == false
      end

      it "should be an Integer given ''" do
        search = User.search
        search.id_gt = ''
        search.id_gt.should == 0
      end

      it "should be an Integer given 1" do
        search = User.search
        search.id_gt = 1
        search.id_gt.should == 1
      end

      it "should be an Integer given '1'" do
        search = User.search
        search.id_gt = "1"
        search.id_gt.should == 1
      end

      it "should be a Float given 1.0" do
        search = Order.search
        search.total_gt = 1.0
        search.total_gt.should == 1.0
      end

      it "should be a Float given '1'" do
        search = Order.search
        search.total_gt = "1"
        search.total_gt.should == 1.0
      end

      it "should be a Float given '1.5'" do
        search = Order.search
        search.total_gt = "1.5"
        search.total_gt.should == 1.5
      end

      it "should be a Range given 1..3" do
        search = Order.search
        search.total_eq = (1..3)
        search.total_eq.should == (1..3)
      end

      it "should be a Date given 'Jan 1, 2009'" do
        search = Order.search
        search.shipped_on_after = "Jan 1, 2009"
        search.shipped_on_after.should == Date.parse("Jan 1, 2009")
      end

      it "should be a Time given 'Jan 1, 2009'" do
        search = Order.search
        search.created_at_after = "Jan 1, 2009"
        search.created_at_after.should == Time.zone.parse("Jan 1, 2009")
      end

      it "should be a Time given 'Jan 1, 2009 9:33AM'" do
        search = Order.search
        search.created_at_after = "Jan 1, 2009 9:33AM"
        search.created_at_after.should == Time.zone.parse("Jan 1, 2009 9:33AM")
      end

      it "should still convert for strings, even if the conversion is skipped for the attribute" do
        search = User.search
        search.whatever_at_after = "Jan 1, 2009 9:33AM"
        search.whatever_at_after.should == Time.zone.parse("Jan 1, 2009 9:33AM")
      end

      it "should convert the time to the current zone" do
        search = Order.search
        now = Time.now
        search.created_at_after = now
        search.created_at_after.should == now.in_time_zone
      end

      it "should skip time zone conversion for attributes skipped" do
        search = User.search
        now = Time.now
        search.whatever_at_after = now
        search.whatever_at_after.should == now.utc
      end

      it "should be an Array and cast it's values given ['1', '2', '3']" do
        search = Order.search
        search.id_equals_any = ["1", "2", "3"]
        search.id_equals_any.should == [1, 2, 3]
      end

      it "should type cast association conditions" do
        search = User.search
        search.orders_total_gt = "10"
        search.orders_total_gt.should == 10
      end

      it "should type cast deep association conditions" do
        search = Company.search
        search.users_orders_total_gt = "10"
        search.users_orders_total_gt.should == 10
      end

      it "should support Rails' date_select and datetime_select out of the box" do
        search = Company.search('created_at_after(1i)' => 2000, 'created_at_after(2i)' => 1, 'created_at_after(3i)' => 1)
        search.created_at_after.should_not be_nil
        search.created_at_after.should == Time.zone.local(2000, 1, 1)
      end
    end
  end

  context "#delete" do
    it "should delete the condition" do
      search = User.search(:username_like => "bjohnson")
      search.delete("username_like")
      search.username_like.should be_nil
      search.conditions["username_like"].should be_nil
    end
  end

  context "#ordering_by" do
    it "should return nil if we aren't ordering" do
      search = User.search
      search.ordering_by.should be_nil
    end

    it "should return the column name for ascending" do
      search = User.search(:order => "ascend_by_first_name")
      search.ordering_by.should == "first_name"
    end

    it "should return the column name for descending" do
      search = User.search(:order => "descend_by_first_name")
      search.ordering_by.should == "first_name"
    end

    it "should handle symbols" do
      search = User.search(:order => :descend_by_first_name)
      search.ordering_by.should == "first_name"
    end
  end

  context "#method_missing" do
    context "setting" do
      it "should call named scopes for conditions" do
        User.search(:age_less_than => 5).proxy_options.should == User.age_less_than(5).proxy_options
      end

      it "should alias exact column names to use equals" do
        User.search(:username => "joe").proxy_options.should == User.username_equals("joe").proxy_options
      end

      it "should recognize conditions with a value of true where the named scope has an arity of 0" do
        User.search(:username_nil => true).proxy_options.should == User.username_nil.proxy_options
      end

      it "should ignore conditions with a value of false where the named scope has an arity of 0" do
        User.search(:username_nil => false).proxy_options.should == {}
      end

      it "should not ignore conditions with a value of false where the named scope does not have an arity of 0" do
        User.search(:username_is => false).proxy_options.should == User.username_is(false).proxy_options
      end

      it "should recognize the order condition" do
        User.search(:order => "ascend_by_username").proxy_options.should == User.ascend_by_username.proxy_options
      end

      it "should pass array values as multiple arguments with arity -1" do
        User.named_scope(:multiple_args, lambda { |*args|
          raise "This should not be an array, it should be 1" if args.first.is_a?(Array)
          {:conditions => ["id IN (?)", args]}
        })
        User.search(:multiple_args => [1,2]).proxy_options.should == User.multiple_args(1,2).proxy_options
      end

      it "should pass array as a single value with arity >= 0" do
        User.named_scope(:multiple_args, lambda { |args|
          raise "This should be an array" if !args.is_a?(Array)
          {:conditions => ["id IN (?)", args]}
        })
        User.search(:multiple_args => [1,2]).proxy_options.should == User.multiple_args([1,2]).proxy_options
      end

      it "should not split out dates or times (big fix)" do
        s = User.search
        s.created_at_after = Time.now
        lambda { s.count }.should_not raise_error
      end

      it "should not include blank values" do
        s = User.search
        s.conditions = {"id_equals" => ""}
        s.proxy_options.should == {}
      end
    end
  end

  context "#respond_to?" do
    it "should respond to created_at_lte" do
      s = User.search
      s.respond_to?(:created_at_lte).should == true
    end

    it "should respond to created_at" do
      s = User.search
      s.respond_to?(:created_at).should == true
    end

    it "should not respond to created_at_or_whatever" do
      s = User.search
      s.respond_to?(:created_at_or_whatever)
    end
  end

  context "delegation" do
    it "should return all when not given any conditions" do
      3.times { User.create }
      User.search.all.length.should == 3
    end

    it "should implement the current scope based on an association" do
      User.create
      company = Company.create
      user = company.users.create
      company.users.search.all.should == [user]
    end

    it "should implement the current scope based on a named scope" do
      User.named_scope(:four_year_olds, :conditions => {:age => 4})
      (3..5).each { |age| User.create(:age => age) }
      User.four_year_olds.search.all.should == User.find_all_by_age(4)
    end

    it "should respond to count" do
      User.create(:username => "bjohnson")
      search1 = User.search(:username => "bjohnson")
      search2 = User.search(:username => "nosnhojb")
      search1.count.should == 1
      search2.count.should == 0
    end

    it "should respond to empty?" do
      User.create(:username => "bjohnson")
      search1 = User.search(:username => "bjohnson")
      search2 = User.search(:username => "nosnhojb")
      search1.empty?.should == false
      search2.empty?.should == true
    end

    it "should delegate to named scopes with arity > 1" do
      User.named_scope :paged, lambda {|start, limit| { :limit => limit, :offset => start }}
      User.create(:username => "bjohnson")
      search = User.search(:username => "bjohnson")
      search.paged(0, 1).count.should == 1
      search.paged(0, 0).count.should == 0
    end
  end

  context "yaml" do
    it "should load yaml" do
      pending
      time = Time.now
      search = User.search(:name_like => "Ben", :created_at_after => time)
      search.current_scope = {:conditions => "1=1"}
      yaml = search.to_yaml
      loaded_search = YAML.load(yaml)
      loaded_search.current_scope.should == {:conditions => "1=1"}
      loaded_search.name_like.should == "Ben"
      loaded_search.created_at_after.should == time
    end
  end
end
