module Searchlogic
  module SearchExt
    module Attributes
      ORDERINGS = [:ascend_by, :descend_by, "ascend_by", "descend_by"]

      def conditions
        @conditions
      end
      def conditions=(hash)
        @conditions = hash
      end
      def klass
        @klass
      end
      def method
        @method
      end
      def ordering_by
        ORDERINGS.select{|key| conditions[key]}.map{ |key| [key, conditions[key]] }.flatten
      end
    end
  end
end