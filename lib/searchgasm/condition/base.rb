module Searchgasm
  module Condition # :nodoc:
    # = Conditions condition
    #
    # The base class for creating a condition. Your custom conditions should extend this class.
    # See Searchgasm::Conditions::Base.register_condition on how to write your own condition.
    class Base
      include Shared::Utilities
      
      attr_accessor :column, :column_for_type_cast, :column_sql, :klass
      class_inheritable_accessor :handle_array_value, :ignore_meaningless_value, :value_type
      self.ignore_meaningless_value = true
    
      class << self
        # Name of the condition type inferred from the class name
        def condition_type_name
          name.split("::").last.underscore
        end
        
        def handle_array_value?
          handle_array_value == true
        end
        
        def ignore_meaningless_value? # :nodoc:
          ignore_meaningless_value == true
        end
        
        # Determines what to call the condition for the model
        #
        # Searchgasm tries to create conditions on each model. Before it does this it passes the model to this method to see what to call the condition. If the condition type doesnt want to create a condition on
        # a model it will just return nil and Searchgasm will skip over it.
        def condition_names_for_model
          []
        end
        
        # Same as condition_name_for_model, but for a model's column obj
        def condition_names_for_column
          [condition_type_name]
        end
      end
    
      def initialize(klass, column_obj = nil, column_type = nil, column_sql = nil)
        self.klass = klass

        if column_obj
          self.column = column_obj.class < ::ActiveRecord::ConnectionAdapters::Column ? column_obj : klass.columns_hash[column_obj.to_s]
          column_type ||= column.type
          self.column_for_type_cast = column.class.new(column.name, column.default.to_s, self.class.value_type.to_s || column_type.to_s, column.null)
          self.column_sql = column_sql || "#{klass.connection.quote_table_name(klass.table_name)}.#{klass.connection.quote_column_name(column.name)}"
        end
      end
    
      # Allows nils to be meaninful values
      def explicitly_set_value=(value)
        @explicitly_set_value = value
      end
    
      # Need this if someone wants to actually use nil in a meaningful way
      def explicitly_set_value?
        @explicitly_set_value == true
      end
      
      def meaningless_value?
        !explicitly_set_value? || (self.class.ignore_meaningless_value? && meaningless?(@value))
      end
      
      # You should refrain from overwriting this method, it performs various tasks before callign your to_conditions method, allowing you to keep to_conditions simple.
      def sanitize(alt_value = nil) # :nodoc:
        return if meaningless_value?
        v = alt_value || value
        if v.is_a?(Array) && !self.class.handle_array_value?
          merge_conditions(*v.collect { |i| sanitize(i) })
        else
          v = v.utc if column && v.respond_to?(:utc) && [:time, :timestamp, :datetime].include?(column.type) && klass.time_zone_aware_attributes && !klass.skip_time_zone_conversion_for_attributes.include?(column.name.to_sym)
          to_conditions(v)
        end
      end
      
      # The value for the condition
      def value
        return @casted_value if @casted_value
        
        if !column_for_type_cast || meaningless_value?
          @casted_value = @value
        else
          @casted_value = @value.is_a?(String) ? column_for_type_cast.type_cast(@value) : @value
        end
      end
    
      # Sets the value for the condition
      def value=(v)
        self.explicitly_set_value = true
        @casted_value = nil
        @value = v
      end
      
      private
        def meaningless?(v)
          return false if v == false
          v.blank?
        end

        def meaningful?(v)
          !meaningless?(v)
        end
        
        def quote_column_name(column_name)
          klass.connection.quote_column_name(column_name)
        end
        
        def quote_table_name(table_name)
          klass.connection.quote_table_name(table_name)
        end
        
        def quoted_table_name
          quote_table_name(klass.table_name)
        end
    end
  end
end