module Searchlogic
  module ActiveRecordExt
    module Scopes
      module Conditions
        class Condition < ActiveRecord::Base
          attr_reader :klass, :args, :block, :value, :table_name, :method_name
          attr_accessor :column_name
          class << self
            def generate_scope(*args)
              new(args[0], args[1], args[2]).scope 
            end
          end

          def initialize(klass, method_name, args, &block)
            @klass = klass
            @method_name = method_name
            @table_name = args[1] || klass.to_s.underscore.pluralize
            @value = args[0]
            @args = args
            @block = block
          end

          def method_missing(method, *args, &block)
            raise NoMethodError.new(method.to_s + " is not recognized by searchlogic")
          end
          
          def self.matcher
            raise NotImplementedError.new("You must define a self.matcher method so searchlogic can mark it as authorized. If your matching method contains already authorized scopes you can define it as nil.")
          end
          
          def applicable?
            raise NotImplementedError.new("You must define an #applicable? method ")
          end
        end
      end
    end
  end
end