module Searchlogic
  module ActiveRecordExt
    module Scopes
      module Conditions
        class GreaterThan < Condition
          include ChronicSupport
          def scope
            if applicable?
              find_column
              klass.where("#{table_name}.#{column_name} > ?", "#{value}")
            end
          end

          private
            def find_column
              @column_name = /(.*)_greater_than/.match(method_name)[1]
            end

            def applicable? 
              !(/_greater_than/ =~ method_name).nil?
            end
        end
      end
    end
  end
end