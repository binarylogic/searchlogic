module Searchlogic
  module ActiveRecordExt
    module Scopes
      module Conditions
        class MethodConstructor
          attr_reader :method_name, :method_parts
          def initialize(method_name)
            @method_name = method_name
            @method_parts = method_name.to_s.split("_or_")
          end

          def methods_array
            methods_without_ending_condition = join_equal_to
            methods_without_ending_condition.map { |m| add_condition(m) }
          end


          private
          def method_without_ending_condition
            method_name.to_s.chomp(ending_alias_condition)
          end

          def ending_alias_condition
            ScopeReflection.new(method_parts.last).predicate 
          end

          def join_equal_to
            methods = []
            method_parts.each_with_index do |item, index| 
              if item == "equal" || item == "equal_to"
                methods.delete_at(-1)
                methods << [method_parts[index-1], item ].join("_or_")
              else
                methods << item
              end
            end
            methods
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
