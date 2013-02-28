module Searchlogic
  module SearchExt
    module Attributes

      def conditions
        @conditions
      end

      def conditions=(hash)
        @conditions = initial_sanitize(hash)
      end

      def klass
        @klass
      end

      def ordering_by
        order = conditions[:order]
        return order if order.nil?  
        order.split("_by_").last
      end

      def method
        @method
      end

    end
  end
end