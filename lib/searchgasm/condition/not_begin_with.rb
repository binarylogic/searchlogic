module Searchgasm
  module Condition
    class NotBeginWith < Base
      class << self
        def condition_names_for_column
          super + ["not_bw", "not_sw", "not_start_with", "not_start", "beginning_is_not", "beginning_not"]
        end
      end
      
      def to_conditions(value)
        begin_with = BeginWith.new
        begin_with.value = value
        being_with.to_conditions.gsub(" LIKE ", " NOT LIKE ")
      end
    end
  end
end