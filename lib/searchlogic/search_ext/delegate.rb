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
          h[k] = v
          h.delete(k) if false_scope_proc?(k, v)
          h
        end
      end

      private 

        def false_scope_proc?(key, value)
          klass.named_scopes.keys.include?(key.to_sym) && !value
        end
    end
  end
end