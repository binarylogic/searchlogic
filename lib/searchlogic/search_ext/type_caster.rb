module Searchlogic
  module SearchExt
    class TypeCaster
      attr_reader :value, :type, :column_for_typecast
      def initialize(value, type)
        @value = value
        @type = type
        @column_for_typecast = set_column(type)
      end

      def call
        if defined?(Chronic) && value.kind_of?(String) && date_or_time?
          column_for_typecast.type_cast(value) || Chronic.try(:parse, sanitize_cdl_in_date(value)) 
        else
          column_for_typecast.type_cast(value)
        end
      end

      private
        def set_column(type)
          ::ActiveRecord::ConnectionAdapters::Column.new("", nil).tap{|col| col.instance_variable_set(:@type, type)}
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
