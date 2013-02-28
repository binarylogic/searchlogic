module Searchlogic
  module SearchExt
    module Base
      def initialize(klass, conditions)
        @klass = klass
        @conditions = initial_sanitize(conditions) #.merge(klass.where_values_hash)
      end

      def clone
        self.class.new(klass, conditions.clone)
      end

      def initial_sanitize(conditions)
        conditions.select{ |k, v| !v.nil? && (authorized_scope?(k) || column_name?(k))}.  
                    inject({}) do |h, (k,v)|
                      h[k.to_sym] = typecast(k, v)
                      h[k.to_sym] = delete_empty_strings(v) if v.kind_of?(Array)
                      value = h[k.to_sym]
                      h.delete(k.to_sym) if (h[k.to_sym].kind_of?(String) || h[k.to_sym].kind_of?(Array)) && h[k.to_sym].empty?
                      h
                    end
      end
      private
        def column_name?(scope)
          !!(klass.column_names.detect{|kcn| kcn == scope.to_s})
        end    

        def delete_empty_strings(value)
          empty_strings_removed = []
          value.each do |v|
            if v.kind_of?(String)
              empty_strings_removed << v unless v.empty?
            else
              empty_strings_removed << v
            end
          end
          empty_strings_removed
        end
    end
  end
end
