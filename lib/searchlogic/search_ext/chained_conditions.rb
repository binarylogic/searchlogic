module Searchlogic
  module SearchExt
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

        def process_scopes(raw_conditions, starting_scope)
          raw_conditions.inject(starting_scope) do |scope, conditions_value|
            if klass.searchlogic_scopes.include?(conditions_value[0]) && conditions_value[1]
              conditions_value[1] == true ? scope.send(conditions_value[0]) : scope.send(conditions_value[0], conditions_value[1])
            else
              scope.send(conditions_value[0], conditions_value[1])
            end
          end        
        end

        def create_scope(scope, value)
          if klass.searchlogic_scopes.include?(scope) && value
            value == true ? klass.send(scope) : klass.send(scope, value)
          else
            klass.send(scope, value)
          end
        end
     end
  end
end