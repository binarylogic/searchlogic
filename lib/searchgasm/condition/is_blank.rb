module Searchgasm
  module Condition
    class IsBlank < Base
      self.ignore_blanks = false
      self.type_cast_value = false
      
      class << self
        def aliases_for_column(column)
          ["#{column.name}_blank"]
        end
      end
      
      def to_conditions(value)
        # Some databases handle null values differently, let AR handle this
        if value == true || value == "true" || value == 1 || value == "1"
          "#{quoted_table_name}.#{quoted_column_name} is NULL or #{quoted_table_name}.#{quoted_column_name} = ''"
        elsif value == false || value == "false" || value == 0 || value == "0"
          "#{quoted_table_name}.#{quoted_column_name} is NOT NULL and #{quoted_table_name}.#{quoted_column_name} != ''"
        end
      end
    end
  end
end