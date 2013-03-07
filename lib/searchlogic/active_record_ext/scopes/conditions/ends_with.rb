module Searchlogic
  module ActiveRecordExt
    module Scopes
      module Conditions
        class EndsWith < Condition
          def scope
            if applicable?
              find_column
              klass.where("#{table_name}.#{column_name} like ?", "%#{value}") 
            end
          end
            def self.matcher
              "_ends_with"
            end
          private
            def value
              args.first
            end

            def find_column
              @column_name = /(.*)_ends_with$/.match(method_name)[1]
            end
            def applicable? 
              !(/(#{klass.column_names.join("|")})#{self.class.matcher}$/ =~ method_name).nil?
            end

        end
      end
    end
  end
end