module Searchlogic
  module ActiveRecordExt
    module Scopes
      module Conditions
        class Blank < Condition
          def scope
            if applicable? && args.first != false          
              find_column
              klass.where("#{table_name}.#{column_name} is null OR #{table_name}.#{column_name} = ? OR #{table_name}.#{column_name} = ?", false ,  "") 
            elsif applicable? && args.first == false
              send_to_not_blank
            else
              false
            end
          end
          private
            def value
              args.first
            end

            def find_column
              @column_name = /(.*)_blank$/.match(method_name)[1]
            end
            def applicable? 
              !(/_blank$/ =~ method_name).nil? 
            end

            def send_to_not_blank
              klass.send(find_column + "_not_blank")
            end
        end
      end
    end
  end
end