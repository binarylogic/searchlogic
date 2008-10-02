module Searchgasm
  module Condition
    class Like < Base
      class << self
        def condition_names_for_column
          super + ["contains", "has"]
        end
      end
      
      def to_conditions(value)
        ["#{column_sql} LIKE ?", "%#{value}%"]
      end
    end
  end
end