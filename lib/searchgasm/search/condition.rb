module Searchgasm
  module Search
    class Condition
      include Utilities
    
      attr_accessor :column, :klass
      attr_reader :value
    
      class << self
        def condition_name
          name.split("::").last.scan(/(.*)Condition/)[0][0].underscore
        end
        
        def name_for_column(column)
          "#{column.name}_#{condition_name}"
        end
        
        def aliases_for_column(column)
          []
        end
        
        def name_for_klass(klass)
          nil
        end
        
        def aliases_for_klass(klass)
          []
        end
        
        def string_column?(column)
          [:string, :text].include?(column.type)
        end

        def comparable_column?(column)
          [:integer, :float, :decimal, :datetime, :timestamp, :time, :date].include?(column.type)
        end
      end
    
      def initialize(klass, column = nil)          
        self.klass = klass
        self.column = column.is_a?(String) ? klass.columns_hash[column] : column
      end
    
      def explicitly_set_value=(value)
        @explicitly_set_value = value
      end
    
      # Need this if someone wants to actually use nil in a meaningful way
      def explicitly_set_value?
        @explicitly_set_value == true
      end
    
      def ignore_blanks?
        true
      end
      
      def name
        column ? self.class.name_for_column(column) : self.class.name_for_klass(klass)
      end
      
      def condition_name
        self.class.condition_name
      end
    
      def quote_column_name(column_name)
        klass.connection.quote_column_name(column_name)
      end
      
      def quoted_column_name
        quote_column_name(column.name)
      end
      
      def quote_table_name(table_name)
        klass.connection.quote_table_name(table_name)
      end
      
      def quoted_table_name
        quote_table_name(klass.table_name)
      end
      
      def sanitize(alt_value = nil)
        return unless explicitly_set_value?
        v = alt_value || value
        if v.is_a?(Array) && !["equals", "does_not_equal"].include?(condition_name)
          merge_conditions(*v.collect { |i| sanitize(i) })
        else
          v = v.utc if column && [:time, :timestamp, :datetime].include?(column.type) && klass.time_zone_aware_attributes && !klass.skip_time_zone_conversion_for_attributes.include?(column.name.to_sym)
          to_conditions(v)
        end
      end
    
      def value
        @value.is_a?(String) ? column.type_cast(@value) : @value
      end
    
      def value=(v)
        return if ignore_blanks? && v.blank?
        self.explicitly_set_value = true
        @value = v
      end
    end
  end
end