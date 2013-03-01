module Searchlogic
  module ActiveRecordExt
    module Scopes
      module Conditions
        class Equals < Condition
          def initialize(klass, method_name, *args, &block)
            @klass = klass
            @method_name = method_name
            @table_name = args[1] || klass.to_s.underscore.pluralize
            @value = args[0]
            @args = *args.flatten
            @block = block
          end

          def scope 
            return nil unless applicable?
            find_column
            if values.first.nil?
              klass.where("#{table_name}.#{column_name} is null")
            else
              klass.where("#{table_name}.#{column_name} IN (?)", values)
            end
          end
          private
            def values
              args.flatten
            end

            def table_name
              klass.to_s.underscore.pluralize
            end

            def find_column
              @column_name = /(.*)_equals$/.match(method_name)[1]
            end

            def applicable? 
              !(/_equals$/ =~ method_name).nil? 
            end
        end
      end
    end
  end
end

