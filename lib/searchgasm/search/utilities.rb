module BinaryLogic
  module Searchgasm
    module Search
      module Utilities
        private
          def merge_conditions(*conditions)
            return conditions.first if conditions.size == 1
            
            conditions_strs = []
            conditions_subs = []
            
            conditions.each do |condition|
              next if condition.blank?
              conditions_strs << condition.first
              conditions_subs += condition[1..-1]
            end
            
            return if conditions_strs.blank?
            
            ["(#{conditions_strs.join(") and (")})", *conditions_subs]
          end
      end
    end
  end
end