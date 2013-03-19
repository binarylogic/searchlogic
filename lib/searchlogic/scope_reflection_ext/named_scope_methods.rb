module Searchlogic
  module ScopeReflectionExt
    module NamedScopeMethods
      def joined_named_scopes
        joined_scopes = all_named_scopes(&:to_s).join("|")
        joined_scopes.empty? ? nil : joined_scopes
      end

      def all_named_scopes
        all_named_scopes_hash.keys
      end

      def all_named_scopes_hash
        ActiveRecord::Base.connection.tables.map{|t| t.singularize.camelize.constantize rescue nil}.
            compact.map{|klass| klass.named_scopes.empty? ? nil : klass.named_scopes}.
            compact.inject({}){ |start, hash| start.merge(hash)}
      end

      def named_scope?
        return false unless joined_named_scopes
        !!(/(#{joined_named_scopes})$/ =~ method)
      end

      def scope_name
        return nil if joined_named_scopes.nil?
        match = /(#{joined_named_scopes})$/.match(method)
        match ? match[1].to_sym : nil
      end     
    end
  end
end
