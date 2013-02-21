module Searchlogic
  class Search < Base
    module MethodMissing
      private
        def method_missing(method, *args, &block)
          scope_name = method.to_s.gsub(/=$/, '').to_sym
          if order = ordering
            conditions_with_ordering(order)
          elsif klass.respond_to?(method.to_sym) && !scope?(scope_name)
            delegate(method, args, &block)
          elsif column_name?(scope_name) || authorized_scope?(scope_name)
            read_or_write_condition(scope_name, args)
          else
            ::Kernel.send(:raise, UnknownConditionError, scope_name.to_s)
          end
        end

        def scope?(method)
          /(#{klass.column_names.join("|")})[_]/ =~ method 
        end

        def ordering
          conditions.find{|c, v| (c.to_sym == :ascend_by) || (c.to_sym == :descend_by) }
        end
    end
  end
end