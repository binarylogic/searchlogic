module BinaryLogic
  module Searchgasm
    module Search
      module ConditionTypes
        class EqualsCondition < Condition
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
      
      Conditions.register_condition(ConditionTypes::EqualsCondition)
    end
  end
end