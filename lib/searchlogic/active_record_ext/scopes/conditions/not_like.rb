module Searchlogic
  module ActiveRecordExt
    module Scopes
      module Conditions
        class NotLike < Condition
          def scope
            if applicable?
              find_column
              klass.where("#{table_name}.#{column_name} not like ?", "%#{value}%") 
            end
          end

          private
            def value
              args.first
            end
            def find_column
              @column_name = /(.*)_not_like$/.match(method_name)[1]
            end
            def applicable? 
              !((/_not_like$/ =~ method_name).nil?)
            end

        end
      end
    end
  end
end