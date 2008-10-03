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
        ["#{column_sql} #{klass.send(:attribute_condition, value)}", *klass.send(:expand_range_bind_variables, [value])]
      end
    end
  end
end