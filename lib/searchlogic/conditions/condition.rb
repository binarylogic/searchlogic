module Searchlogic
  module Conditions
    class Condition
      attr_reader :klass, :method
      def initialize(klass, method)
        puts "initializeing" 
        @klass = klass
        @method = method
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