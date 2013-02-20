module Searchlogic
  module ActiveRecordExt
    module Scopes
      module Conditions
        class DoesNotEqual < Condition
          def scope
            if applicable?
              find_column
              klass.where("#{table_name}.#{column_name} != ?", "#{value}")  
            end
          end

          private
            def value
              args.first
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