# module Searchlogic
#   module ActiveRecordExt
#     module Scopes
#       def self.included(klass)
#         klass.class_eval do 
#           extend Conditions
#         end
#       end
#     end
#   end
# end


# ActiveRecord::Base.send(:include, Searchlogic::ActiveRecordExt::Scopes)
