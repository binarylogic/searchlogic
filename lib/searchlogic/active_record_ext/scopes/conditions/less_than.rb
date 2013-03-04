module Searchlogic
  module ActiveRecordExt
    module Scopes
      module Conditions
        class LessThan < Condition
          include ChronicSupport
          def scope
            if applicable?
              find_column
              klass.where("#{table_name}.#{column_name} < ?", "#{value}") 
            end
          end
            
            def self.matcher
              "_less_than"
            end

          private

            def find_column
              @column_name = /(.*)_less_than$/.match(method_name)[1]
            end

        end
      end
    end
  end
end