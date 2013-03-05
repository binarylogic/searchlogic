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
          scope_conditions.inject(initial_scope) do |scope, (condition, value)| 
            create_scope(scope, condition, value)
          end
        end

        private
          def ordering?(condition)
            condition.to_s == "order"
          end

          def create_scope(scope, condition, value)
            std_condition = ScopeReflection.convert_alias(condition)
            scope_lambda = initial_scope.named_scopes[std_condition] ? initial_scope.named_scopes[std_condition][:scope] : nil
            if scope_lambda && !(value).nil?
              if scope_lambda.arity == 0 && value == true
                scope.send(std_condition)
              elsif scope_lambda.arity == 1
                scope.send(std_condition, value)
              else
                scope.send(std_condition, *value)
              end
            elsif ordering?(std_condition)
              scope.send(value)            
            else
              scope.send(std_condition, *value)
            end          
          end
      end
    end
  end
end
