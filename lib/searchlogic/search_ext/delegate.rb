Dir[File.dirname(__FILE__) + '/delegate/*.rb'].each { |f| require(f) }
module Searchlogic
  module SearchExt
    module Delegate
      def delegate(method_name, args, &block)
        args = nil if args.empty?
        scope = conditions.inject(klass) do |current_scope, (condition, value)| 
            false_scope_proc?(condition, value) ? current_scope : create_scope(current_scope, condition, value) 
        end
        args.nil? ? scope.send(method_name, &block) : scope.send(method_name, args, &block)
      end

      private 

        def create_scope(curr_scope, condition, value)
          std_condition = ScopeReflection.convert_alias(condition, value)
          scope_lambda = klass.named_scopes[std_condition] ? klass.named_scopes[std_condition][:scope] : nil
          method_and_args = [std_condition, *value]
          # binding.pry
          if scope_lambda && scope_lambda.arity == 0 && value == true || ordering?(condition)
            curr_scope.send(std_condition)
          else
            curr_scope.send(*method_and_args)
          end
        end
        def false_scope_proc?(key, value)
          klass.named_scopes.keys.include?(key.to_sym) && !value
        end
    end
  end
end