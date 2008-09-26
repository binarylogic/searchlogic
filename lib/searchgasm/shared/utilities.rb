module Searchgasm
  module Shared
    module Utilities # :nodoc:
      private
        def merge_conditions(*conditions)
          options = conditions.extract_options!
          conditions.delete_if { |condition| condition.blank? }
          return if conditions.blank?
          return conditions.first if conditions.size == 1
        
          conditions_strs = []
          conditions_subs = []
        
          conditions.each do |condition|
            next if condition.blank?
            arr_condition = [condition].flatten
            conditions_strs << arr_condition.first
            conditions_subs += arr_condition[1..-1]
          end
        
          return if conditions_strs.blank?
        
          join = options[:any] ? "OR" : "AND"
          conditions_str = "(#{conditions_strs.join(") #{join} (")})"
        
          return conditions_str if conditions_subs.blank?
        
          [conditions_str, *conditions_subs]
        end
        
        def merge_joins(*joins)
          joins.delete_if { |join| join.blank? }
          return if joins.blank?
          return joins.first if joins.size == 1
          
          new_joins = []
          joins.each do |join|
            case join
            when Array
              new_joins += join
            else
              new_joins << join
            end
          end
          
          new_joins.compact.uniq
        end
        
        # "meaningful" is subjective which is why this is not a core extension like .blank?
        def meaningless?(value)
          return false if value == false
          value.blank?
        end
        
        def meaningful?(value)
          !meaningless?
        end
    end
  end
end