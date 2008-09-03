module BinaryLogic
  module Searchgasm
    module Search
      module ConditionTypes
        class DoesNotEqualCondition < Condition
          class << self
            def aliases_for_column(column)
              ["#{column.name}_is_not", "#{column.name}_not"]
            end
          end
          
          def ignore_blanks?
            false
          end
          
          def to_conditions(value)
            # Delegate to equals and then change
            condition = EqualsCondition.new(klass, column)
            condition.value = value
            
            sql = condition.sanitize
            sql.gsub!(/ IS /, " IS NOT ")
            sql.gsub!(/ BETWEEN /, " NOT BETWEEN ")
            sql.gsub!(/ IN /, " NOT IN ")
            sql.gsub!(/=/, "!=")
            sql
          end
        end
      end
      
      Conditions.register_condition(ConditionTypes::DoesNotEqualCondition)
    end
  end
end