module Searchlogic
  module ScopeReflectionExt
    module InstanceMethods
      def condition
        return method if !!(searchlogic_methods.detect{ |slm| /#{slm.to_s}$/ =~ method}) || named_scope?
        Alias.convert_alias(method)
      end


      def authorized?
        !!(Alias.match(method)) || named_scope? || /#{searchlogic_methods.join("|")}/ =~ method
      end

      def predicate
        return Alias.match(method)[1] if Alias.match(method)
        return nil if /#{joined_named_scopes}$/ =~ method && joined_named_scopes
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

      def named_scope_on_klass?
        (named_scope? && !start_with_association?)
      end

      def start_with_association?
        tables = ActiveRecord::Base.tables.join("|")
        !!(/^#{tables}_/ =~ method)
      end
    end
  end
end
