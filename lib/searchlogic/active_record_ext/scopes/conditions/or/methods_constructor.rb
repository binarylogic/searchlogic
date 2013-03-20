module Searchlogic
  module ActiveRecordExt
    module Scopes
      module Conditions
        class MethodConstructor
          attr_reader :method_name, :method_parts
          def initialize(method_name)
            @method_name = method_name
            @method_parts = method_name.to_s.split(/_or_(?!equal)/)
          end

          def methods_array
            method_parts.map { |m| add_condition(m) }
          end

          private

          def ending_alias_condition
            @ending_alias_condition ||= ScopeReflection.new(method_name).predicate 
          end          

          def add_condition(method)
            return method if /(_any|_all)$/ =~ method
            if ScopeReflection.authorized?(method)
              grouping = /(_any|_all)$/.match(ending_alias_condition)
              grouping.nil? ? method : method + grouping 
            else
              method + ending_alias_condition
            end
          end     
        end
      end
    end
  end
end
