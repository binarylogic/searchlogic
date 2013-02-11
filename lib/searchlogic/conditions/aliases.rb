module Searchlogic
  module Conditions
    class Aliases < Condition
      def scope
        if applicable?
          
        end
      end

      private
        def applicable?
          binding.pry
          /is|eq|not_equal_to|is_not|not|ne|lt|before|lte|gt|after|gte|contains|includes|does_not_include|bw|not_begin_with|ew|not_end_with|nil|not_nil|present/.match(method_name)
        end
    end
  end
end

      COMPARISON_CONDITIONS = {
        :equals => [:is, :eq],
        :does_not_equal => [:not_equal_to, :is_not, :not, :ne],
        :less_than => [:lt, :before],
        :less_than_or_equal_to => [:lte],
        :greater_than => [:gt, :after],
        :greater_than_or_equal_to => [:gte],
      }

      WILDCARD_CONDITIONS = {
        :like => [:contains, :includes],
        :not_like => [:does_not_include],
        :begins_with => [:bw],
        :not_begin_with => [:does_not_begin_with],
        :ends_with => [:ew],
        :not_end_with => [:does_not_end_with]
      }

      BOOLEAN_CONDITIONS = {
        :null => [:nil],
        :not_null => [:not_nil],
        :empty => [],
        :blank => [],
        :not_blank => [:present]
      }
