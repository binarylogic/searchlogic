module Searchlogic
  module Search
    class SearchProxy < BasicObject
      module MethodMissing
        private
          def method_missing(method, *args, &block)
            scope_name = method.to_s.gsub(/=$/, '').to_sym
              ###TODO WHITELIST ALLOWED SCOPES                              ::Object.send(:binding).pry                            
            if !!(/=$/ =~ method) && !!klass.column_names.detect{|kcn| scope_name.to_s.include?(kcn)}
              conditions[scope_name] = args.first
              ###Use whitelist scope names here to check if user is trying to read scope attribute so can return nil if not present
            elsif !!klass.column_names.detect{|kcn| scope_name.to_s.include?(kcn)}
              conditions[scope_name]
            else              
              chained_conditions
            end
          end
          private
            def contains_column_referenced_in_method?(method)
              
            end
      end
    end
  end
end