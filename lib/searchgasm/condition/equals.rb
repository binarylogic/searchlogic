module Searchgasm
  module Condition
    class Equals < Base
      class << self
        def aliases_for_column(column)
          ["#{column.name}", "#{column.name}_is"]
        end
      end
      
      def ignore_blanks?
        false
      end
      
      def to_conditions(value)
        # Let ActiveRecord handle this
        klass.send(:sanitize_sql_hash_for_conditions, {column.name => value})
      end
    end
  end
end