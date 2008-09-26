module Searchgasm
  module Condition
    class Blank < Base
      self.type_cast_sql_type = "boolean"
      
      class << self
        def aliases_for_column(column)
          ["#{column.name}_is_blank"]
        end
      end
      
      def to_conditions(value)
        # Some databases handle null values differently, let AR handle this
        if value == true
          "#{quoted_table_name}.#{quoted_column_name} is NULL or #{quoted_table_name}.#{quoted_column_name} = ''"
        elsif value == false
          "#{quoted_table_name}.#{quoted_column_name} is NOT NULL and #{quoted_table_name}.#{quoted_column_name} != ''"
        end
      end
    end
  end
end