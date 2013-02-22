module Searchlogic
  module ActiveRecordExt
    module Scopes
      module Conditions
        class LessThanOrEqualTo < Condition
          include ChronicSupport
          def scope
            if applicable?
              find_column
              klass.where("#{table_name}.#{column_name} <= ?", "#{value}") 
            end
          end

          private

            def find_column
              @column_name = /(.*)_less_than_or_equal_to$/.match(method_name)[1]
              
            end
            def applicable? 
              !(/_less_than_or_equal_to$/ =~ method_name).nil?
            end      
        end
      end
    end
  end
end