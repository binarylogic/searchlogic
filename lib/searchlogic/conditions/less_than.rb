module Searchlogic
  module Conditions
    class LessThan < Condition
      def scope
        if applicable?
          find_column
          klass.where("#{table_name}.#{column_name} < ?", "#{value}") 
        end
      end

      private
        def value
          args.first.kind_of?(String) ? parsed_string_input : args.first
        end

        def find_column
          @column_name = /(.*)_less_than$/.match(method_name)[1]
        end
        def applicable? 
          !(/_less_than$/ =~ method_name).nil? 
        end
        def parsed_string_input
          if defined?(Chronic)
            Chronic.parse(args.first)
          else
            raise "Chronic is not defined, add it to your gemfile if you want to use semantic names for times"
          end
        end
    end
  end
end