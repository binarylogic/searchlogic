module Searchlogic
  module SearchExt
    module Attributes

      def conditions
        @conditions ||= {}
      end

      def conditions=(hash)
        hash.each do |k,v|
          next if (v.is_a?(String) && v.blank?) || v.nil?
          send("#{k}=", v)
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