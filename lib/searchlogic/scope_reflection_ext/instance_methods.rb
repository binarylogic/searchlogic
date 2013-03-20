module Searchlogic
  module ScopeReflectionExt
    module InstanceMethods
      def condition
        return method if !!(searchlogic_methods.detect{ |slm| /#{slm.to_s}$/ =~ method}) || named_scope? 
        Alias.convert_alias(method)
      end


      def authorized?
        !!(Alias.match(method)) || named_scope? || /#{searchlogic_methods.join("|")}$/ =~ method
      end

      def predicate
        return nil if /#{joined_named_scopes}$/ =~ method && joined_named_scopes
        return Alias.match(method)[1] if Alias.match(method)
        begin
          /(#{searchlogic_methods.sort_by(&:size).reverse.join("|")})_(any|all)$/.match(method).try(:[], 0) || /(#{searchlogic_methods.sort_by(&:size).reverse.join("|")})$/.match(method)[0] 
        rescue NoMethodError  => e
          raise Searchlogic::ActiveRecordExt::Scopes::InvalidConditionError.new(e)
        end
      end

      def column?
        begin
          /^(#{klass.column_names.join("|")})/ =~ method ||  /^(ascend_by_|descend_by_)(#{klass.column_names.join("|")})/ =~ method
        rescue NoMethodError
          raise UninitializedClassError.new
        end
      end

      def scope?
        begin
          /^(#{klass.named_scopes.keys.join("|")})/ =~ method ||  /^(ascend_by_|descend_by_)(#{klass.named_scopes.keys.join("|")})/ =~ method
        rescue
          raise UninitializedClassError.new
        end
      end
    end
  end
end
