module Searchlogic
  module Search
    class SearchProxy < BasicObject
      module Ordering
        def conditions_with_ordering(order)
          order_method = order.join("_")
          conditions.delete(order.first)
          conditions.empty? ? klass.send(order_method) : chained_conditions.send(order_method)
        end
      end
    end
  end
end