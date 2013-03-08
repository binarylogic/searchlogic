module Searchlogic
  module ScopeReflectionExt
    module NamedScopeMethods
      def joined_named_scopes
        joined_scopes = all_named_scopes(&:to_s).join("|")
        joined_scopes.empty? ? nil : joined_scopes
      end

      def all_named_scopes
        ActiveRecord::Base.connection.tables.map{|t| t.singularize.camelize.constantize rescue nil}.compact.map{|klass| klass.named_scopes.keys}.flatten
      end

      def named_scope?(method)
        return false if all_named_scopes.map(&:to_s).join("|").empty?
        !!(/(#{joined_named_scopes})$/ =~ method)
      end      
    end
  end
end
