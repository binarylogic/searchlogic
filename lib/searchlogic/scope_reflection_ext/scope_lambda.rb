module Searchlogic
  module ScopeReflectionExt
    module ScopeLambda

      def scope_lambda
        if all_named_scopes.include?(method.to_sym)
          all_named_scopes_hash[method.to_sym][:scope]
        else
          nil
        end
      end

      def scope_lambda_type
        all_named_scopes.include?(method) ? all_named_scopes_hash[method.to_sym][:type] : nil
      end
    end
  end
end
