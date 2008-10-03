module Searchgasm
  module Condition
    class Blank < Base
      self.value_type = :boolean
      
      class << self
        def condition_names_for_column
          super + ["is_blank"]
        end
      end
      
      def to_conditions(value)
        if value == true
          "#{column_sql} is NULL or #{column_sql} = ''"
        elsif value == false
          "#{column_sql} is NOT NULL and #{column_sql} != ''"
        end
      end
    end
  end
end