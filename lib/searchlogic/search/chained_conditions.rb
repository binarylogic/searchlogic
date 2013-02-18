module Searchlogic
  module Search
    class SearchProxy < BasicObject
      module ChainedConditions
        ##TODO change chaing for 0 conditions 1, and many
        def chained_conditions          
          return klass.all if conditions.empty?
          return chained_scoped_conditions
        end

        private
        def chained_scoped_conditions
          conditions_for_results = conditions.clone
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

        def replace_nil(conditions_value)
          return conditions_value if conditions_value.last

          klass.column_names.select{|kcn| conditions_value.first.to_s.include?(kcn)}                                                                             

        end
      end
    end
  end
end