module Searchgasm
  module Condition
    class DuringEvening < Base
      class << self
        def name_for_column(column)
          return unless time_column?(column)
          super
        end
        
        def aliases_for_column(column)
          column_names = [column.name]
          column_names << column.name.gsub(/_(at|on)$/, "") if column.name =~ /_(at|on)$/
          
          aliases = []
          column_names.each { |column_name| aliases += ["#{column_name}_in_the_evening", "#{column_name}_in_evening", "#{column_name}_evening"] }
          aliases << "#{column_names.last}_during_evening" if column_names.size > 1
          aliases
        end
      end
      
      def to_conditions(value)
        evening_start = 17
        evening_end = 22
        
        # Need to set up a funcion in each adapter for dealing with dates. Mysql uses HOUR(), sqlite uses strftime(), postgres uses date_part('hour', date). Could potentially be a pain in the ass.
        # Also, you could set up an hour = condition, and leverage that to do this.
        if value == true
          ["#{quoted_table_name}.#{quoted_column_name} >= ? AND #{quoted_table_name}.#{quoted_column_name} <= ?", value]
      end
    end
  end
end