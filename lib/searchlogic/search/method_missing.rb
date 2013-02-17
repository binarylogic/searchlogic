module Searchlogic
  module Search
    class SearchProxy < BasicObject
      module MethodMissing
        private
          def method_missing(method, *args, &block)
            scope_name = method.to_s.gsub(/=$/, '')
            if klass.respond_to?(scope_name) && scope_name != "all"
              @conditions[scope_name] = args.first
            # elsif @conditions.key?(method)
              # @conditions.merge(args)
            else
              chained_conditions
          end
        end
      end
    end
  end
end