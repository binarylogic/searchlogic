require 'pry'
module Searchlogic
  module Conditions
    class Condition < ActiveRecord::Base
      attr_reader :klass, :method_name, :args, :column_name, :block, :value 
      attr_accessor :or_conditions

      delegate :table_name, :to => :klass

      class << self
        def generate_scope(*args)
          new(args[0], args[1], args[2]).scope 
        end
      end

      def initialize(klass, method_name, args, &block)
        @klass = klass
        @method_name = method_name
        @column_name = find_columns.first  
        @value = args.first
        @or_conditions = ""
        @args = args
        @block = block
      end

      def applicable?
        raise NotImplementedError.new("You need to define a #applicable method")
      end

      def find_columns
        columns = klass.column_names.select{ |cn| method_name.to_s.include?(cn)}
      end
      def calc_or_conditions
        raise NotImplementedError.new("You need to define a #calc_or_conditions method") 
      end

    end
  end
end