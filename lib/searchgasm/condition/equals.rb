module Searchgasm
  module Condition
    class Equals < Base
      self.handle_array_value = true
      self.ignore_meaningless_value = false
      
      class << self
        def condition_names_for_column
          super + ["", "is"]
        end
      end
      
      def to_conditions(value)
        # Let ActiveRecord handle this
        klass.send(:sanitize_sql_hash_for_conditions, {column.name => value})
      end
    end
  end
end