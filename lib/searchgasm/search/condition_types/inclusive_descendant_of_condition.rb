module Searchgasm
  module Search
    module ConditionTypes
      class InclusiveDescendantOfCondition < TreeCondition
        include Search::Utilities
        
        def to_conditions(value)
          condition = DescendantOfCondition.new(klass, column)
          condition.value = value
          merge_conditions(["#{quoted_table_name}.#{quote_column_name(klass.primary_key)} = ?", (value.is_a?(klass) ? value.send(klass.primary_key) : value)], condition.sanitize, :any => true)
        end
      end
    end
    
    Conditions.register_condition(ConditionTypes::InclusiveDescendantOfCondition)
  end
end