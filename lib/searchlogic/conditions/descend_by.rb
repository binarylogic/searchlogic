require 'pry'
module Searchlogic
  module Conditions
    class DescendBy < Condition

      def initialize(klass, method_name, args, &block)
        @klass = klass
        @column_name = parse_method(method_name)
      end

      def scope
        klass.order("#{table_name}.#{column_name} DESC")
      end

      private
        def value
          args.first
        end
  
        def parse_method(method)
          /^descend_by_(.*)/.match(method)[1]
        end
    end
  end
end