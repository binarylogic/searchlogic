module Searchlogic
  module SearchExt
    module Attributes

      def conditions
        @conditions ||= {}
      end

      def conditions=(hash)
        ::Object.__send__(:raise, ::ArgumentError.new("Attributes must be a hash")) if !(hash.kind_of?(Hash))
        hash.each do |k,v|
          next if (v.is_a?(String) && v.blank?) || v.nil?
          __send__("#{k}=", v)
        end
      end

      def ordering_by
        conditions[:order]
      end

      def klass
        @klass
      end
      
      def method
        @method
      end

    end
  end
end