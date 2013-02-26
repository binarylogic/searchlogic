require 'spec_helper'

describe Searchlogic::SearchExt::TypeCast do 

 context "type casting" do
    context '#castboolean' do
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
    context "#castintger" do 
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

    xit "should be a Range given 1..3" do
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
      Time.zone = "EST"
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

      search.created_at_after.should eq(now.in_time_zone)
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
      search = User.search
      search.orders_line_items_price = "10"
      search.orders_line_items_price == 10
    end

    xit "should support Rails' date_select and datetime_select out of the box" do
      search = Company.search('created_at_after(1i)' => 2000, 'created_at_after(2i)' => 1, 'created_at_after(3i)' => 1)
      search.created_at_after.should_not be_nil
      search.created_at_after.should == Time.zone.local(2000, 1, 1)
    end
  end
end