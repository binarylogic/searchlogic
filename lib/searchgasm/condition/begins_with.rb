module Searchgasm
  module Condition
    class BeginsWith < Base
      class << self
        def name_for_column(column)
          return unless string_column?(column)
          super
        end
        
        def aliases_for_column(column)
          ["#{column.name}_bw", "#{column.name}_sw", "#{column.name}_starts_with", "#{column.name}_start"]
        end
      end
      
      def to_conditions(value)
        ["#{quoted_table_name}.#{quoted_column_name} LIKE ?", "#{value}%"]
      end
    end
  end
end