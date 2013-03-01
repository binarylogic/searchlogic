Dir[File.dirname(__FILE__) + '/delegate/*.rb'].each { |f| require(f) }
module Searchlogic
  module SearchExt
    module Delegate
      def delegate(method_name, args, &block)
        args = nil if args.empty?
        scope_generator = ScopeGenerator.new(sanitized_conditions, klass)
        args.nil? ? scope_generator.scope.send(method_name, &block) : scope_generator.scope.send(method_name, args, &block)
      end
        ##Sanitized conditions in this class so they're only changed once
        ##the method has been delegated. This allows for the original search object to stay the same

      def sanitized_conditions
        conditions.inject({}) do |h, (k,v)|
          h[k] = typecast(k,v)
          h.delete(k) if false_scope_proc?(k, v)
          h
        end
      end

      private 

        def false_scope_proc?(key, value)
          klass.searchlogic_scopes.include?(key.to_sym) && !value
        end

        def column_or_association?(key)
          !!(klass.column_names.detect{|kcn| kcn.to_sym == key} || klass.reflect_on_all_associations.detect{ |association| key.to_s.include?(association.name.to_s) && !authorized_scope?(key.to_s) })
        end

        def ordering?(scope_name)
          scope_name.to_s == "order"
        end
    end
  end
end