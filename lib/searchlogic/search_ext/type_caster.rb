module Searchlogic
  module SearchExt
    class TypeCaster
      attr_reader :value, :type, :method
      ##TODO Memoize col types
      def self.call(type, method, *vals)
        new(type, method, vals).cast 
      end


      def initialize(type, method, *values)
        values.flatten!
        @value = values.size == 1 ? values.first : values
        @type = type
        @method = method
      end


      def cast(val = self.value)
        return val if ordering?(method)
        case val
        when Range then Range.new(cast(val.first), cast(val.last))
        when Array then val.collect{|v| cast(v)}
        else
          parse(val)
        end
      end        


        def self.memoized_types
          @memoized_types ||= {}
        end
      private

        def parse(input)
          if defined?(Chronic) && input.kind_of?(String) && date_or_time?
            column_type.type_cast(input) || Chronic.try(:parse, sanitize_cdl_in_date(input)) 
          else
            column_type.type_cast(input)
          end
        end

        def column_type
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

        def ordering?(scope_name)
          scope_name.to_s == "order"
        end

    end
  end
end
