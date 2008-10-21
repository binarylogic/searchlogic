module Searchgasm
  module Condition
    class Ilike < Base
      class << self
        def condition_names_for_column
          super + ["icontains", "ihas"]
        end
      end
      
      def to_conditions(value)
        ["#{column_sql} ILIKE ?", "%#{value}%"]
      end
    end
  end
end