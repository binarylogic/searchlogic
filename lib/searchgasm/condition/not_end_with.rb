module Searchgasm
  module Condition
    class NotEndWith < Base
      class << self
        def condition_names_for_column
          super + ["not_ew", "not_end", "end_is_not", "end_not"]
        end
      end
      
      def to_conditions(value)
        ends_with = EndsWith.new
        ends_with.value = value
        ends_with.to_conditions.gsub(" LIKE ", " NOT LIKE ")
      end
    end
  end
end