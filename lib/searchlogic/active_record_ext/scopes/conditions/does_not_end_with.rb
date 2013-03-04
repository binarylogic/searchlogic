module Searchlogic
  module ActiveRecordExt
    module Scopes
      module Conditions
        class DoesNotEndWith < Condition
          def scope
            if applicable?
              find_column
              klass.where("#{table_name}.#{column_name} not like ?", "%#{value}")
            end
          end
            
            def self.matcher
              "_does_not_end_with"
            end
          private
            def value
              args.first
            end

            def find_column
              @column_name = /(.*)_does_not_end_with$/.match(method_name)[1]
            end

        end
      end
    end
  end
end