module Searchgasm
  module Condition
    class NotNil < Base
      class << self
        def condition_names_for_column
          super + ["is_not_nil", "is_not_null", "not_null"]
        end
      end
      
      def to_conditions(value)
        is_nil = Nil.new
        is_nil.value = !value
        is_nil.to_conditions
      end
    end
  end
end