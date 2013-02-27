module Searchlogic
  module SearchExt
    module Base
      def initialize(klass, conditions)
        @klass = klass

        @conditions = sanitize(conditions)
      end

      def clone
        self.class.new(klass, conditions.clone)
      end

      def sanitize(conditions)
        conditions = conditions.first if conditions.kind_of?(Array)
        conditions.select{ |k, v| !v.nil? && (authorized_scope?(k) || column_name?(k))}.  
                    inject({}) { |h, (k,v)| h[k.to_sym] = typecast(k, v); h}
      end

      def column_name?(scope)
        !!(klass.column_names.detect{|kcn| kcn == scope.to_s})
      end    
    end
  end
end
