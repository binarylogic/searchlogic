require 'pry'
module Searchlogic
  module Conditions
    class Condition < ActiveRecord::Base
      attr_reader :klass, :args, :column_name, :block, :value, :table_name
      attr_accessor :or_conditions, :method_name

      class << self
        def generate_scope(*args)
          new(args[0], args[1], args[2]).scope 
        end
      end

      def initialize(klass, method_name, args, &block)
        @klass = klass
        @method_name = method_name
        @table_name = args[1] || klass.to_s.downcase.pluralize
        @value = args.first
        @column_name = method_name
        @or_conditions = ""
        @args = args
        @block = block
      end

      def applicable?
        raise NotImplementedError.new("You need to define a #applicable method")
      end

      def calc_or_conditions
        raise NotImplementedError.new("You need to define a #calc_or_conditions method") 
      end

    end
  end
end