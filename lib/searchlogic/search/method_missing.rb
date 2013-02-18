module Searchlogic
  module Search
    class SearchProxy < BasicObject
      module MethodMissing
        private
          def method_missing(method, *args, &block)
            scope_name = method.to_s.gsub(/=$/, '').to_sym
              ###TODO WHITELIST ALLOWED SCOPES                            
            if !!(/=$/ =~ method) && !!klass.column_names.detect{|kcn| scope_name.to_s.include?(kcn)}
              conditions[scope_name] = args.first
              ###TODO Use whitelist scope names here to check if user is trying to read scope attribute so can return nil if not present
            elsif !!klass.column_names.detect{|kcn| scope_name.to_s.include?(kcn)}
              args.empty? ? return_value(scope_name) : assign_condition(scope_name, args.first)
            elsif method.to_sym == :all
              chained_conditions
            elsif method.to_sym == :count
              count_conditions
            else
              super
            end
          end

          def return_value(key)
            conditions[key]
          end

          def assign_condition(cond_name, value)
            conditions[cond_name] = value
            self
          end
      end
    end
  end
end