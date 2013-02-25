module Searchlogic
  module SearchExt
    module MethodMissing
      private
        def method_missing(method, *args, &block)
          scope_name = method.to_s.gsub(/=$/, '').to_sym
          if order = ordering
            conditions_with_ordering(order)
          elsif authorized_scope?(scope_name) || column_name?(scope_name) || method.to_s.include?('=')
            read_or_write_condition(scope_name, args)
          else
            delegate(method, args, &block)
          end
        end
        def ordering
          conditions.find{|c, v| (c.to_sym == :ascend_by) || (c.to_sym == :descend_by) }
        end
    end
  end
end