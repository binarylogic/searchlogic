module Searchlogic
  module ActiveRecordExt
    module Scopes
      module Conditions
        class BeginsWith < Condition
          def scope
            if applicable?
              find_column
              table_name = klass.name.downcase.pluralize
              klass.where("#{table_name}.#{column_name} like ? ", "#{value}%") 
            end
          end
          
          def self.matcher
            "begins_with"
          end
          private
            def value
              args.first
            end
            def find_column
              @column_name = /(.*)_begins_with$/.match(method_name)[1]
            end
            def applicable? 
              !(/#{self.class.matcher}$/ =~ method_name).nil?
            end


        end
      end
    end
  end
end