module Searchlogic
  class Search < Base
    module ChainedConditions
      def chained_conditions(sanitized_conditions = self.conditions)          
        conditions_for_results = sanitized_conditions.clone
        first_params = conditions_for_results.shift          
        initial_scope = create_scope(first_params[0], first_params[1])
        if conditions_for_results.empty?
          initial_scope
        else
          process_scopes(conditions_for_results, initial_scope)
        end
      end

      private
        def process_scopes(raw_condition, starting_scope)
          raw_condition.inject(starting_scope) do |scope, conditions_value|
            if klass.searchlogic_scopes.include?(conditions_value[0]) && conditions_value[1]
              scope.send(conditions_value[0])
            else
              scope.send(conditions_value[0], conditions_value[1])
            end
          end        
        end
        def create_scope(scope, value)
          if klass.searchlogic_scopes.include?(scope) && value
            klass.send(scope)
          else
            klass.send(scope, value)
          end
        end
    end
  end
end