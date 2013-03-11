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

      def named_scope?(method)
        return false if all_named_scopes.map(&:to_s).join("|").empty?
        !!(/(#{joined_named_scopes})$/ =~ method)
      end

      def scope_name(method)
        begin
          return nil if joined_named_scopes.nil?
          /(#{joined_named_scopes})$/.match(method)[1].to_sym
        rescue
          nil
        end
      end      
    end
  end
end
