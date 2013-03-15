Dir[File.dirname(__FILE__) + '/delegate/*.rb'].each { |f| require(f) }
module Searchlogic
  module SearchExt
    module Delegate
      def delegate(method_name, args, &block)
        begin 
          conditions.inject(klass) do |current_scope, (condition, value)| 
            false_scope_proc?(condition, value) ? current_scope : create_scope(current_scope, condition, value) 
          end.send(method_name, *args, &block)
        rescue NoMethodError => e
          raise(Searchlogic::ActiveRecordExt::Scopes::InvalidConditionError.new(e))
        end
      end

      private 
        def create_scope(curr_scope, condition, value)
          std_condition = ScopeReflection.convert_alias(klass, :method => condition, :value => value)
          scope_name = ScopeReflection.scope_name(std_condition)
          scope_lambda = ScopeReflection.all_named_scopes_hash.try(:[], scope_name)
          if (scope_lambda.try(:[], :type) == :boolean && value == true) || ordering?(condition)
            curr_scope.send(std_condition)
          elsif scope_lambda.try(:[], :scope).try(:arity) == 1
            curr_scope.send(std_condition, value)
          else
            [value].flatten.size == 1 ? curr_scope.send(std_condition, value) : curr_scope.send(std_condition, *value) 
          end
        end

        def false_scope_proc?(key, value)
          ScopeReflection.named_scope?(key) && !value
        end
    end
  end
end