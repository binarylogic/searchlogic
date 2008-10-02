module Searchgasm
  module Condition
    class BeginsWith < Base
      class << self
        def condition_names_for_column
          super + ["bw", "sw", "starts_with", "start"]
        end
      end
      
      def to_conditions(value)
        ["#{column_sql} LIKE ?", "#{value}%"]
      end
    end
  end
end