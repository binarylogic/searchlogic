module Searchlogic
  class Search
    module Ordering
      # Returns the column we are currently ordering by
      def ordering_by
        @ordering_by ||= order && order.to_s.gsub(/^(ascend|descend)_by_/, '')
      end

      def ordering_direction
        @ordering_direction ||= order && order.to_s.match(/^(ascend|descend)_by_/).try(:[], 1)
      end
    end
  end
end