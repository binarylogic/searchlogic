module Searchgasm
  module Condition # :nodoc:
    # = Conditions condition
    #
    # The base class for creating a condition. Your custom conditions should extend this class.
    # See Searchgasm::Conditions::Base.register_condition on how to write your own condition.
    class Base
      include Shared::Utilities
      
      attr_accessor :column, :klass
      class_inheritable_accessor :ignore_meaningless, :type_cast_sql_type
      self.ignore_meaningless = true
    
      class << self
        # Name of the condition inferred from the class name
        def condition_name
          name.split("::").last.gsub(/Condition$/, "").underscore
        end
        
        # I pass you a column you tell me what to call the condition. If you don't want to use this condition for the column
        # just return nil
        def name_for_column(column)
          "#{column.name}_#{condition_name}"
        end
        
        # Alias methods for the column condition.
        def aliases_for_column(column)
          []
        end
        
        def ignore_meaningless? # :nodoc:
          ignore_meaningless == true
        end
        
        # Sane as name_for_column but for the class as a whole. For example the tree methods apply to the class as a whole and not
        # specific columns. Any condition that applies to columns should probably return nil here.
        def name_for_klass(klass)
          nil
        end
        
        # Alias methods for the klass condition
        def aliases_for_klass(klass)
          []
        end
        
        # A utility method for using in name_for_column. Determines if a column contains a date.
        def date_column?(column)
          [:datetime, :date, :timestamp].include?(column.type)
        end
        
        # A utility method for using in name_for_column. Determines if a column contains a date and a time.
        def datetime_column?(column)
          [:datetime, :timestamp, :time, :date].include?(column.type)
        end
        
        # A utility method for using in name_for_column. For example the keywords condition only applied to string columns, the great than condition doesnt.
        def string_column?(column)
          [:string, :text].include?(column.type)
        end

        # A utility method for using in name_for_column. For example you wouldn't want a string column to use the greater thann condition, but you would for an integer column.
        def comparable_column?(column)
          [:integer, :float, :decimal, :datetime, :timestamp, :time, :date].include?(column.type)
        end
        
        # A utility method for using in name_for_column. Determines if a column contains a time.
        def time_column?(column)
          [:datetime, :timestamp, :time].include?(column.type)
        end
      end
    
      def initialize(klass, column = nil)          
        self.klass = klass
        self.column = column.is_a?(String) ? klass.columns_hash[column] : column
      end
    
      # Allows nils to be meaninful values
      def explicitly_set_value=(value)
        @explicitly_set_value = value
      end
    
      # Need this if someone wants to actually use nil in a meaningful way
      def explicitly_set_value?
        @explicitly_set_value == true
      end
      
      # A convenience method for the name of the method for that specific column or klass
      def name
        column ? self.class.name_for_column(column) : self.class.name_for_klass(klass)
      end
      
      # A convenience method for the name of this condition
      def condition_name
        self.class.condition_name
      end
    
      # Quotes a column name properly for sql.
      def quote_column_name(column_name)
        klass.connection.quote_column_name(column_name)
      end
      
      # A convenience method for using when writing your sql in to_conditions. This is the proper way to use a column name in a query for most databases
      def quoted_column_name
        quote_column_name(column.name)
      end
      
      # Quotes a table name properly for sql
      def quote_table_name(table_name)
        klass.connection.quote_table_name(table_name)
      end
      
      # A convenience method for using when writing your sql in to_conditions. This is the proper way to use a table name in a query for most databases
      def quoted_table_name
        quote_table_name(klass.table_name)
      end
      
      # You should refrain from overwriting this method, it performs various tasks before callign your to_conditions method, allowing you to keep to_conditions simple.
      def sanitize(alt_value = nil) # :nodoc:
        return unless explicitly_set_value?
        v = alt_value || value
        if v.is_a?(Array) && !["equals", "does_not_equal"].include?(condition_name)
          merge_conditions(*v.collect { |i| sanitize(i) })
        else
          v = v.utc if column && [:time, :timestamp, :datetime].include?(column.type) && klass.time_zone_aware_attributes && !klass.skip_time_zone_conversion_for_attributes.include?(column.name.to_sym)
          to_conditions(v)
        end
      end
    
      # The value for the condition
      def value
        @value.is_a?(String) ? column_for_type_cast.type_cast(@value) : @value
      end
    
      # Sets the value for the condition
      def value=(v)
        return if self.class.ignore_meaningless? && meaningless?(v)
        self.explicitly_set_value = true
        @value = v
      end
      
      private
        def column_for_type_cast
          @column_for_type_cast ||= self.class.type_cast_sql_type ? self.column.class.new(column.name, column.default.to_s, self.class.type_cast_sql_type.to_s, column.null) : column
        end
    end
  end
end