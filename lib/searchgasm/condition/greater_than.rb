module Searchgasm
  module Condition
    class GreaterThan < Base
      class << self
        def name_for_column(column)
          return unless comparable_column?(column)
          super
        end
        
        def aliases_for_column(column)
          column_names = [column.name]
          column_names << column.name.gsub(/_at$/, "") if [:datetime, :timestamp, :time, :date].include?(column.type) && column.name =~ /_at$/
          
          aliases = []
          column_names.each { |column_name| aliases += ["#{column_name}_gt", "#{column_name}_after"] }
          aliases
        end
      end
      
      def to_conditions(value)
        ["#{quoted_table_name}.#{quoted_column_name} > ?", value]
      end
    end
  end
end