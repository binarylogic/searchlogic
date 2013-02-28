module Searchlogic
  module SearchExt
    module Base
      def initialize(klass, conditions)
        @klass = klass

        @conditions = initial_sanitize(conditions)
      end

      def clone
        self.class.new(klass, conditions.clone)
      end

      def initial_sanitize(conditions)
        conditions.select{ |k, v| !v.nil? && (authorized_scope?(k) || column_name?(k))}.  
                    inject({}) { |h, (k,v)| h[k.to_sym] = typecast(k, v); h}
      end
      private
      
        def column_name?(scope)
          !!(klass.column_names.detect{|kcn| kcn == scope.to_s})
        end    
    end
  end
end
