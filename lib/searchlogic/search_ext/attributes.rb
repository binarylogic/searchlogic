module Searchlogic
  module SearchExt
    module Attributes

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

    end
  end
end