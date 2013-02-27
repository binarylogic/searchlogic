module Searchlogic
  module SearchExt
    module Attributes

      def conditions
        @conditions
      end

      def conditions=(hash)
        @conditions = sanitize(hash)
      end

      def klass
        @klass
      end

      def ordering_by
        order = conditions[:order]
        return order unless order
        order.split("_by_").last
      end

      def method
        @method
      end

    end
  end
end