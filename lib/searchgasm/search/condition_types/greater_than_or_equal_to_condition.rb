module Searchgasm
  module Search
    module ConditionTypes
      class GreaterThanOrEqualToCondition < Condition
        class << self
          def name_for_column(column)
            return unless comparable_column?(column)
            super
          end
          
          def aliases_for_column(column)
            ["#{column.name}_gte", "#{column.name}_at_least"]
          end
        end
        
        def to_conditions(value)
          ["#{quoted_table_name}.#{quoted_column_name} >= ?", value]
        end
      end
    end
    
    Conditions.register_condition(ConditionTypes::GreaterThanOrEqualToCondition)
  end
end