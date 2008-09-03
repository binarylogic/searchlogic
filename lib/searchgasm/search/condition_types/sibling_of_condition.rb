module BinaryLogic
  module Searchgasm
    module Search
      module ConditionTypes
        class SiblingOfCondition < TreeCondition
          include Search::Utilities
          
          def to_conditions(value)
            parent_association = klass.reflect_on_association(:parent)
            foreign_key_name = (parent_association && parent_association.options[:foreign_key]) || "parent_id"
            parent_id = (value.is_a?(klass) ? value : klass.find(value)).send(foreign_key_name)
            condition = ChildOfCondition.new(klass, column)
            condition.value = parent_id
            merge_conditions(["#{quoted_table_name}.#{quote_column_name(klass.primary_key)} != ?", (value.is_a?(klass) ? value.send(klass.primary_key) : value)], condition.sanitize)
          end
        end
      end
      
      Conditions.register_condition(ConditionTypes::SiblingOfCondition)
    end
  end
end