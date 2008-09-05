module Searchgasm
  module Search
    module ConditionTypes
      class TreeCondition < Condition
        class << self
          def name_for_column(column)
            nil
          end
          
          def name_for_klass(klass)
            return unless klass.reflect_on_association(:parent) && klass.reflect_on_association(:children)
            condition_name
          end
        end
      end
    end
  end
end