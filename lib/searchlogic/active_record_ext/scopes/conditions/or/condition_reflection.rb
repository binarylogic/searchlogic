module Searchlogic
  module ActiveRecordExt
    module Scopes
      module Conditions
        class MethodConstructor
          GROUPING_CONDITION = ["_any", "_all"]
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
            return nil if /#{ScopeReflection.joined_named_scopes}$/ =~ method_name && ScopeReflection.joined_named_scopes
            begin
              /(#{ScopeReflection.searchlogic_methods.sort_by(&:size).reverse.join("|")})$/.match(method_name)[0]
            rescue NoMethodError => e
              raise InvalidConditionError.new(e)
            end
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
            return method if /(#{GROUPING_CONDITION.join("|")})$/ =~ method
            if has_condition?(method) || scope?(method) 
              add_group(method)
            elsif GROUPING_CONDITION.include?(ending_alias_condition)
              method + secondary_condition + ending_alias_condition
            else
              method + ending_alias_condition
            end
          end

          def secondary_condition
             /(#{ScopeReflection.searchlogic_methods.sort_by(&:size).reverse.join("|")})_(all|any)$/.match(method_parts.last)[1]
          end

          def add_group(method)
            group_by = /(#{GROUPING_CONDITION.join("|")})$/.match(method_parts.last)
            return method if group_by.nil?
            method + group_by[1]

          end

          def scope?(method)
            joined_scopes = ScopeReflection.all_named_scopes.join("|")
            return false if joined_scopes.blank?
            !!(/(#{joined_scopes})$/ =~ method)
          end

          def has_condition?(method)
            !!(/(#{ScopeReflection.aliases.join("|")}|#{ScopeReflection.searchlogic_methods.join("|")})/.match(method) )
          end          
        end
      end
    end
  end
end
