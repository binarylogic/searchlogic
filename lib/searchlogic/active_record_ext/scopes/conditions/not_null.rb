module Searchlogic
  module ActiveRecordExt
    module Scopes
      module Conditions
        class NotNull < Condition
          def scope
            if applicable? && args.first != false          
              find_column
              klass.where("#{table_name}.#{column_name} is not NULL")
            elsif applicable? && args.first == false
              send_to_null
            else
              false
            end
          end
            def self.matcher
              "_not_null"
            end
          private
            def value
              args.first
            end
            
            def find_column
              @column_name = /(.*)_not_null$/.match(method_name)[1]
            end

            def applicable? 
              !(/^(#{klass.column_names.join("|")})#{self.class.matcher}$/ =~ method_name).nil?
            end

            def send_to_null
              klass.__send__(find_column + "_null")
            end
        end
      end
    end
  end
end