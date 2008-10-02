module Searchgasm
  module Condition
    class Nil < Base
      self.value_type = :boolean
      
      class << self
        def condition_names_for_column
          super + ["is_nil", "is_null", "null"]
        end
      end
      
      def to_conditions(value)
        if value == true
          "#{column_sql} is NULL"
        elsif value == false
          "#{column_sql} is NOT NULL"
        end
      end
    end
  end
end