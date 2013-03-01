module Searchlogic
  module SearchExt
    module Delegate
      class ScopeGenerator
        attr_accessor  :scope_conditions, :initial_scope
        def initialize(scope_conditions, klass)
          self.scope_conditions = scope_conditions
          self.initial_scope = klass

        end

        def scope
          scope_conditions.empty? ? initial_scope : full_scope
        end

        private
          def starting_scope
            first_conditions = with_any_condition || scope_conditions.shift
            return nil unless first_conditions
            create_scope(klass, first_conditions[0], first_conditions[1])
          end

          def ordering?(condition)
            condition.to_s == "order"
          end

          def create_scope(scope, condition, value)
            if scope.searchlogic_scopes.include?(condition) && !(value).nil?
              ##What if scope takes an arguement of true?
              value == true ? scope.send(condition) : scope.send(condition, *value)
            elsif ordering?(condition)
              scope.send(value)            
            else
              scope.send(condition, *value)
            end          
          end

          def full_scope
            scope_conditions.inject(initial_scope) do |scope, (condition, value)| 
              create_scope(scope, condition, value)
            end
          end
      end
    end
  end
end
