require File.dirname(__FILE__) + '/benchmark_helper.rb'

times = 1

Benchmark.bm(20) do |x|
  x.report("1st instantiation:")  { Account.new_search }
  x.report("2nd instantiation:")  { Account.new_search }
  
  # Now that we see the benefits of caching, lets cache the rest of the classes and perform the rest of the tests,
  # so that they are fair
  User.new_search
  Order.new_search
  
  x.report("Local ordering:") do
    times.times do
      Account.new_search(:order_by => :name).sanitize
    end
  end
  
  x.report("Advanced ordering:") do
    times.times do
      Account.new_search(:order_by => {:users => {:orders => :total}}).sanitize
    end
  end
  
  x.report("Local conditions:") do
    times.times do
      Account.new_search(:conditions => {:name_like => "Binary"}).sanitize
    end
  end
  
  x.report("Advanced conditions:") do
    times.times do
      Account.new_search(:conditions => {:users => {:orders => {:total_gt => 1}}}).sanitize
    end
  end
  
  x.report("Its complicated:") do
    times.times do
      Account.new_search(:conditions => {:users => {:orders => {:total_gt => 1, :created_at_after => Time.now}, :first_name_like => "Ben"}, :name_begins_with => "Awesome"}, :per_page => 20, :page => 2, :order_by => {:users => {:orders => :total}}, :order_as => "ASC").sanitize
    end
  end
end