module Searchlogic
  class Search < Base
    module ChainedConditions
      def chained_conditions(sanitized_conditions = self.conditions)          
        return klass.all if conditions.empty?
        return chained_scoped_conditions(sanitized_conditions)
      end

      private
      def chained_scoped_conditions(conditions_to_chain)
        conditions_for_results = conditions_to_chain.clone
        first_params = conditions_for_results.shift          
        initial_scope = klass.send(first_params[0], first_params[1]) 
        if conditions_for_results.empty?
          initial_scope
        else 
            conditions_for_results.inject(initial_scope) do |scope, conditions_value|
            scope.send(conditions_value[0], conditions_value[1])
          end
        end
      end
    end
  end
end