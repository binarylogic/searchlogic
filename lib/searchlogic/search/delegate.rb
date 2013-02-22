module Searchlogic
  class Search < Base
    module Delegate
      def delegate(method_name, args, &block)
        args = nil if args.empty?
        if conditions.empty?
          klass.send(method_name, args, &block)
        else
          chained_conditions(sanitized_conditions).send(method_name, args, &block)            
        end
      end
      private 
        ##Sanitized conditions in this class so they're only changed once
        ##the method has been delegated. This allows for the original search object to stay the same

        def sanitized_conditions
          conditions.inject({}) do |h, (k,v)|
            key, value = replace_nils(k, v)
            new_key, new_value = implicit_equals(key, value)
            h[new_key] = new_value
            h.delete(k) if false_scope_proc?(k, v)
            h
          end
        end
        def replace_nils(original_key, value)
          new_key = (original_key.to_s + "_null").to_sym
          value.nil? ? [new_key, true] : [original_key, value]
        end
        def false_scope_proc?(key, value)
          klass.searchlogic_scopes.include?(key.to_sym) && !value
        end

        def implicit_equals(original_key, value)
          new_key = (original_key.to_s + "_equals").to_sym
          column_name_as_condition?(original_key) ? [new_key, value] : [original_key, value]
        end

        def column_name_as_condition?(key)
          !!(klass.column_names.detect{|kcn| kcn.to_sym == key})
        end
    end
  end
end