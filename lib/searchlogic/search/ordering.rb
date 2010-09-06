module Searchlogic
  class Search
    module Ordering
      # Returns the column we are currently ordering by
      def ordering_by
        order && order.to_s.gsub(/^(ascend|descend)_by_/, '')
      end
    end
  end
end