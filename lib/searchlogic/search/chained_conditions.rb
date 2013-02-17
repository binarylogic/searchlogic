module Searchlogic
  module Search
    class SearchProxy < BasicObject
      module ChainedConditions
        def chained_conditions
          first_params = conditions.shift
          initial_scope = klass.send(first_params[0], first_params[1])
          conditions.inject(initial_scope){|scope, conditions| klass.send(conditions[0], conditions[1])}
        end
      end
    end
  end
end