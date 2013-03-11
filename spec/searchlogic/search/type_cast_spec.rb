require 'spec_helper'

describe Searchlogic::SearchExt::TypeCast do 

 context "type casting" do
  it "should cast values with custom scopes" do 
    User.scope :custom, lambda { User.where("age IN (10)")}
  end

  it "should raise error on incorrectly spelled columns" do 
    expect{User.search(:agee_eq => 10)}.to raise_error
  end


    context "mass assignment" do 
      it "should typecast chronic phrases on mass assignment" do 
        search = User.search(:created_at_after => "yesterday")
        search.created_at_after.should be_kind_of Time
      end
    end


    context '#castboolean' do
      it "should be a boolean  given col_null" do 
        search = User.search(:name_blank => "true")
        search.name_blank.should eq(true)
      end
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
        search.id_nil.should eq(false)
      end

      it "should be a Boolean given '0'" do
        search = User.search
        search.id_nil = "0"
        search.id_nil.should == false
      end
    end

    context "#castinteger" do 
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
    end

    context "#cast_float" do 
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
    end

    context "range" do 
      it "should be a Range given 1..3" do
        search = Order.search
        search.total_eq = (1..3)
        search.total_eq.should eq((1..3))
      end
    end
    context "#cast_date" do 
      it "should be a Date given 'Jan 1, 2009'" do
        search = Order.search
        search.shipped_on_after = "Jan 1, 2009"
        search.shipped_on_after.should == Date.parse("Jan 1, 2009")
      end
      it "should accept a Date Object" do 
        search = Order.search
        search.shipped_on_before = Date.today
        search.shipped_on_before.should eq(Date.today)
      end
    end
    context "#cast_time" do 
      it "should accept a Time Object" do 
        search = Order.search
        search.created_at_before = Time.new("14,13,20")
        search.created_at_before.should eq(Time.new("14,13,20"))
      end
      it "should be a Time given 'Jan 1, 2009'" do
        search = Order.search
        Time.zone = "EST"

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
        search.created_at_after.should eq(now.in_time_zone)
      end

      it "should skip time zone conversion for attributes skipped" do
        search = User.search
        now = Time.now
        search.whatever_at_after = now
        search.whatever_at_after.should == now.utc
      end
    end
    context "with arrays"
      it "should be an Array and cast it's values given ['1', '2', '3']" do
        search = Order.search
        search.id_equals_any = ["1", "2", "3"]
        search.id_equals_any.should == [1, 2, 3]
      end
    end
    context "associations" do 

      it "should type cast association conditions" do
        search = User.search
        search.orders_total_gt = "10"
        search.orders_total_gt.should == 10
      end

      it "should type cast deep association conditions" do
        search = User.search
        search.orders_line_items_price_eq = "10"
        search.orders_line_items_price_eq.should eq(10)
      end

      it "doesn't incorrectly match columns" do 
        User.create(:username => "James", :company => Company.create)
        search = Company.search 
        search.users_username_eq("James")
        search.count.should eq(1)
      end
  end
  context "named Scopes" do 
    it "typcasts named scope with arity = 1 when explicity set type" do 
      User.create(:created_at => Date.new(2014,2,2))
      class User; scope :too_old, lambda{ |date| where(created_at_greater_than(date))};end
      search = User.search
      search.too_old = "2014, 2, 1"
      search.conditions[:too_old].should eq("2014, 2, 1")
      User.named_scopes[:too_old][:type] = :date      
      search.too_old = "2014, 2, 1"
      search.conditions[:too_old].should be_kind_of(Date)
    end

  end
end