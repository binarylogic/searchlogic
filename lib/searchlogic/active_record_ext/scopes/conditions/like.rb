module Searchlogic
  module ActiveRecordExt
    module Scopes
      module Conditions
        class Like < Condition

          def scope
            if applicable?
              column_name = find_column[1]
              klass.where("#{table_name}.#{column_name} like ?", "%#{value}%")  
            end

          end
           def self.matcher
              "_like"
            end

          private
            def applicable? 
              !(/(#{klass.column_names.join("|")})#{self.class.matcher}$/ =~ method_name).nil?
            end

            def find_column
              /(.*)_like$/.match(method_name)
            end
        end
      end
    end
  end
end