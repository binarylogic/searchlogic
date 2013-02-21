# require 'enumerable'
# module Searchlogic
#   class Search < Base
#     include Enumerable
#     def each(&block)
#       self.all.each do |member|
#         block.call(member)
#       end
#     end 
#   end
# end