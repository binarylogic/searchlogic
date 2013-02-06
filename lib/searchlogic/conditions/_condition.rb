module Searchlogic
  module Conditions
    class Condition < ActiveRecord::Base
      attr_reader :klass, :method_name, :args, :column_name, :block
      delegate :table_name, :to => :klass

      class << self
        def generate_scope(*args)
          new(args[0], args[1], args[2]).scope
        end
      end

      def initialize(klass, method_name, args, &block)
        @klass = klass
        @column_name = method_name
        @args = args
        @block = block
      end

      def applicable?
        raise NotImplementedError.new("You need to define a #applicable method")
      end
    end
  end
end