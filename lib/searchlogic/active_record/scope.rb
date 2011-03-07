module Searchlogic
  module ActiveRecord
    # Makes sure chained scopes work correctly. ActiveRecord calls scopes.include?(name) in the ActiveRecord::NamedScopes::Scope class
    # This presented a problem because searchlogic scopes are called on the fly. So we need to try and create the scope before they
    # check for this. Thats what this module is all about.
    module Scope
      def self.included(klass)
        klass.class_eval do
          alias_method_chain :method_missing, :searchlogic
        end
      end

      private
        def method_missing_with_searchlogic(*args)
          method = args.first
          if !scopes.include?(method)
            begin
              proxy_scope.proxy_reflection.klass.respond_to?(method)
            rescue NoMethodError => e
              proxy_scope.respond_to?(method)
            end
          end
          method_missing_without_searchlogic(*args)
        end
    end
  end
end