Dir[File.dirname(__FILE__) + '/delegate/*.rb'].each { |f| require(f) }
module Searchlogic
  module SearchExt
    module Delegate
      def delegate(method_name, args, &block)
        begin 
          conditions.inject(klass) do |current_scope, (condition, value)| 
            false_scope_proc?(condition, value) ? current_scope : create_scope(current_scope, condition, value) 
          end.__send__(method_name, *args, &block)
        rescue NoMethodError => e
          ::Object.send(:raise, Searchlogic::ActiveRecordExt::Scopes::InvalidConditionError.new(e))
        end
      end

      private 
        def create_scope(curr_scope, condition, value)
          scope_reflection = ScopeReflection.new(condition)
          if scope_reflection.scope_lambda_type == :boolean && value == true || ordering?(condition)
            curr_scope.__send__(scope_reflection.condition)
          elsif scope_reflection.scope_lambda.try(:arity) == 1
            curr_scope.__send__(scope_reflection.condition, value)
          else
            [value].flatten.size == 1 ? curr_scope.__send__(scope_reflection.condition, value) : curr_scope.__send__(scope_reflection.condition, *value) 
          end
        end

        def false_scope_proc?(key, value)
          ScopeReflection.new(key).named_scope? && !value
        end
    end
  end
end