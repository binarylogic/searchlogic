module Searchlogic
  module ActiveRecordExt
    module Scopes
      module Conditions
        class LessThanOrEqualTo < Condition
          def scope
            if applicable?
              find_column
              klass.where("#{table_name}.#{column_name} <= ?", "#{value}") 
            end
          end

          private
            def value
              args.first.kind_of?(String) ? parsed_string_input : args.first
            end
      
            def find_column
              @column_name = /(.*)_less_than_or_equal_to$/.match(method_name)[1]
              
            end
            def applicable? 
              !(/_less_than_or_equal_to$/ =~ method_name).nil?
            end
            def parsed_string_input
              if defined?(Chronic)
                Chronic.parse(args.first)
              else
                "Strings are not a valid argument unless you're searching for a time and have Chronic in your gemfile"
              end
            end        
        end
      end
    end
  end
end