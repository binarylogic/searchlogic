module Searchlogic
  module ScopeReflectionExt
    module InstanceMethods
      def condition
        return method if !!(searchlogic_methods.detect{ |slm| /#{slm.to_s}$/ =~ method}) || named_scope? 
        Alias.convert_alias(method)
      end

      def all_named_scopes_hash
        ActiveRecord::Base.connection.tables.map{|t| t.singularize.camelize.constantize rescue nil}.
            compact.map{|klass| klass.named_scopes.empty? ? nil : klass.named_scopes}.
            compact.inject({}){ |start, hash| start.merge(hash)}
      end

      def authorized?
        !!(Alias.match(method)) || named_scope? || /#{searchlogic_methods.join("|")}$/ =~ method
      end

      def predicate
        return nil if /#{joined_named_scopes}$/ =~ method && joined_named_scopes
        return Alias.match(method)[0] if Alias.match(method)
        begin
          /(#{searchlogic_methods.sort_by(&:size).reverse.join("|")})_(any|all)$/.match(method).try(:[], 0) || /(#{searchlogic_methods.sort_by(&:size).reverse.join("|")})$/.match(method)[0] 
        rescue NoMethodError 
          msg = "`#{method}' is not defined in searchlogic"
          raise NoMethodError.new(msg)
        end

      end
    end
  end
end
