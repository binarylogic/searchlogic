module Searchlogic
  module ActiveRecordExt
    module Scopes
      module Conditions
        class DoesNotEqual < Condition
          def scope 
            return nil unless applicable?
            find_column
            if values.first.nil?
              klass.where("#{table_name}.#{column_name} is not null")
            else
              klass.where("#{table_name}.#{column_name} not in (?)", values)
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
              @column_name = /(.*)_does_not_equal$/.match(method_name)[1]
            end
            
            def applicable? 
              !(/_does_not_equal$/ =~ method_name).nil?
            end
        end
      end
    end
  end
end