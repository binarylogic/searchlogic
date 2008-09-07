module Searchgasm
  module Search
    module Protection
      # Options that are allowed when protecting against SQL injections (still checked though)
      SAFE_OPTIONS = Base::SPECIAL_FIND_OPTIONS + [:conditions, :limit, :offset]
      
      # Options that are not allowed, at all, when protecting against SQL injections
      VULNERABLE_OPTIONS = Base::VALID_FIND_OPTIONS - SAFE_OPTIONS
      
      def self.included(klass)
        klass.class_eval do
          attr_reader :protect
          alias_method_chain :options=, :protection
        end
      end
      
      def options_with_protection=(values)
        return unless values.is_a?(Hash)
        self.protect = values.delete(:protect) if values.has_key?(:protect) # make sure we do this first
        frisk!(values) if protect?
        self.options_without_protection = values
      end
      
      def protect=(value)
        conditions.protect = value
        @protect = value
      end
      
      def protect?
        protect == true
      end
      
      private
        def order_by_safe?(order_by, alt_klass = nil)
          return true if order_by.blank?
          
          k = alt_klass || klass
          column_names = k.column_names
          
          [order_by].flatten.each do |column|
            case column
            when Hash
              return false unless k.reflect_on_association(column.keys.first.to_sym)
              return false unless order_by_safe?(column.values.first, column.keys.first.to_s.classify.constantize)
            when Array
              return false unless order_by_safe?(column)
            else
              return false unless column_names.include?(column.to_s)
            end
          end
          
          true
        end
        
        def frisk!(options)
          options.symbolize_keys.assert_valid_keys(SAFE_OPTIONS)
          raise(ArgumentError, ":order_by can only contain colum names in the string, hash, or array format") unless order_by_safe?(get_order_by_value(options[:order_by]))
        end
    end    
  end
end