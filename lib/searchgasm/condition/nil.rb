module Searchgasm
  module Condition
    class Nil < Base
      self.type_cast_sql_type = "boolean"
      
      class << self
        def aliases_for_column(column)
          ["#{column.name}_is_nil", "#{column.name}_is_null", "#{column.name}_null"]
        end
      end
      
      def to_conditions(value)
        if value == true
          "#{quoted_table_name}.#{quoted_column_name} is NULL"
        elsif value == false
          "#{quoted_table_name}.#{quoted_column_name} is NOT NULL"
        end
      end
    end
  end
end