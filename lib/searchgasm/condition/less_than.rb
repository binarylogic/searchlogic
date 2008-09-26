module Searchgasm
  module Condition
    class LessThan < Base
      class << self
        def name_for_column(column)
          return unless comparable_column?(column)
          super
        end
        
        def aliases_for_column(column)
          column_names = [column.name]
          column_names << column.name.gsub(/_(at|on)$/, "") if datetime_column?(column) && column.name =~ /_(at|on)$/
          
          aliases = []
          column_names.each { |column_name| aliases += ["#{column_name}_lt", "#{column_name}_before"] }
          aliases << "#{column_names.last}_less_than" if column_names.size > 1
          aliases
        end
      end
      
      def to_conditions(value)
        ["#{quoted_table_name}.#{quoted_column_name} < ?", value]
      end
    end
  end
end