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
              __send___to_not_blank
            else
              false
            end
          end

          def self.matcher 
            "_blank"
          end          
          private
            def value
              args.first
            end

            def find_column
              @column_name = /(.*)_blank$/.match(method_name)[1]
            end

            def applicable? 
              !(/^(#{klass.column_names.join("|")})#{self.class.matcher}$/ =~ method_name).nil?
            end

            def __send___to_not_blank
              klass.__send__(find_column + "_not_blank")
            end
        end
      end
    end
  end
end