module Searchlogic
  module Conditions
    class Condition
      attr_reader :klass, :column
      def initialize(klass, column)
        @klass = klass
        @column = column.split("_").first
      end

      def self.to_str
        "Condition"
      end

      def applicable?(name)
        raise NotImplementedError.new("You need to define a #applicable? method")
      end

      private
      def column_names
        klass.column_names
      end
    end
  end
end