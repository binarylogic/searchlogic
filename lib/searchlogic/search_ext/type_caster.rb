module Searchlogic
  module SearchExt
    class TypeCaster
      attr_reader :value, :type
      
      def self.call(type, *vals)
        new(type, vals).cast 
      end

      def self.memoized_types
        @memoized_types ||= {}
      end

      def initialize(type, *values)
        values.flatten!
        @value = values.size == 1 ? values.first : values
        @type = type
      end


      def cast(val = self.value)
        case val
        when Range then Range.new(cast(val.first), cast(val.last))
        when Array then val.collect{|v| cast(v)}
        else
          type_cast(val)
        end
      end        
      private

        def type_cast(input)
          if defined?(Chronic) && input.kind_of?(String) && date_or_time?
            column_type.type_cast(input) || Chronic.try(:parse, sanitize_cdl_in_date(input)) 
          else
            column_type.type_cast(input)
          end
        end

        def column_type
          return self.class.memoized_types[type.to_sym] if self.class.memoized_types[type.to_sym]
          set_column = ::ActiveRecord::ConnectionAdapters::Column.new("", nil).tap{|col| col.instance_variable_set(:@type, type)}
          self.class.memoized_types[type.to_sym] = set_column
          set_column
        end

        def date_or_time?
          type == :datetime || type == :date || type == :time
        end

        def sanitize_cdl_in_date(value)
          value.gsub(",", "/")
        end
    end
  end
end
