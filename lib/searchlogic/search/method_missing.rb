module Searchlogic
  module Search
    class SearchProxy < BasicObject
      module MethodMissing
        private
          def method_missing(method, *args, &block)
            scope_name = method.to_s.gsub(/=$/, '')
              ###TODO WHITELIST ALLOWED SCOPES
            if /=$/ =~ method && klass.column_names.detect{|kcn| scope_name.include?(kcn)}

              conditions[scope_name] = args.first
            elsif conditions[scope_name]
              conditions[scope_name]
            else
              chained_conditions
            end
          end
      end
    end
  end
end