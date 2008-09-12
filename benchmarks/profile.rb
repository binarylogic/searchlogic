require File.dirname(__FILE__) + '/benchmark_helper.rb'
require "ruby-prof"

Account.new_search
User.new_search
Order.new_search

RubyProf.start

# Put profile code here

result = RubyProf.stop

printer = RubyProf::FlatPrinter.new(result)
printer.print(STDOUT, 0)