module Searchgasm
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
  end
end