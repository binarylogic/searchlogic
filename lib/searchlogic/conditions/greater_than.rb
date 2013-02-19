module Searchlogic
  module Conditions
    class GreaterThan < Condition
      def scope
        if applicable?
          find_column
          klass.where("#{table_name}.#{column_name} > ?", "#{value}")
        end
      end

      private
        def value
          args.first.kind_of?(String) ? parsed_string_input : args.first
        end

        def find_column
          @column_name = /(.*)_greater_than/.match(method_name)[1]
        end

        def applicable? 
          !(/_greater_than/ =~ method_name).nil?
        end

        def parsed_string_input
          if defined?(Chronic)
            Chronic.parse(args.first)
          else
            raise "Strings are not a valid argument unless you're searching for a time and have Chronic in your gemfile"
          end
        end
    end
  end
end