module Searchlogic
  module Search
    class SearchProxy < BasicObject
      module CountConditions
        def count_conditions
          chained_scoped_conditions.all.count
        end
      end
    end
  end
end