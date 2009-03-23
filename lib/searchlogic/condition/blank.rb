module Searchlogic
  module Condition
    class Blank < Base
      self.value_type = :boolean
      
      class << self
        def condition_names_for_column
          super + ["is_blank"]
        end
      end
      
      def to_conditions(value)
        case column.type
        when :boolean
          return "(#{column_sql} IS NULL or #{column_sql} = '' or #{column_sql} = false)" if value == true
          return "(#{column_sql} IS NOT NULL and #{column_sql} != '' and #{column_sql} != false)" if value == false
        else
          return "(#{column_sql} IS NULL or #{column_sql} = '')" if value == true
          return "(#{column_sql} IS NOT NULL and #{column_sql} != '')" if value == false
        end
      end
    end
  end
end