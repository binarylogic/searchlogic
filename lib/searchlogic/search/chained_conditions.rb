require 'pry'
module Searchlogic
  module Search
    class SearchProxy < BasicObject
      module ChainedConditions
        ##TODO change chaing for 0 conditions 1, and many
        def chained_conditions
          first_params = conditions.shift
          initial_scope = klass.send(first_params[0], first_params[1])

          conditions.inject(initial_scope){|scope, conditions| scope.send(conditions[0], conditions[1])}
        end

        private
        def build_
          
        end
      end
    end
  end
end