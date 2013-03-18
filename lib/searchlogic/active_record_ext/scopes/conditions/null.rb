module Searchlogic
  module ActiveRecordExt
    module Scopes
      module Conditions
        class Null < Condition

          def scope
            if applicable? && args.first != false          
              find_column
              klass.where("#{table_name}.#{column_name} is NULL")
            elsif applicable? && args.first == false
              __send___to_not_null
            else
              false
            end
          end
            def self.matcher
              "_null"
            end          

          private
          
            def value
              args.first
            end

            def find_column
              @column_name = (/(.*)_null/).match(method_name)[1]
            end

            def applicable? 
              !(/^(#{klass.column_names.join("|")})#{self.class.matcher}$/ =~ method_name).nil?
            end


            def __send___to_not_null
              klass.__send__(find_column + "_not_null")
            end
        end
      end
    end
  end
end