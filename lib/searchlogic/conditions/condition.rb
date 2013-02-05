module Searchlogic
  module Conditions
    class Condition
      attr_reader :klass, :column
      def initialize(klass, column)
        @klass = klass
        @column = column.split("_").first
        puts "Done initializing"
      end

      private
      def column_names
        klass.column_names
      end
      def scope(name)
        raise NotImplementedError.new("You need to define a #scope method")
      end

    end
  end
end