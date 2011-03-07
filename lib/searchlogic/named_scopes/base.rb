module Searchlogic
  module NamedScopes
    module Base
      def condition?(name)
        existing_condition?(name)
      end

      private
        def existing_condition?(name)
          return false if name.blank?
          @valid_scope_names ||= scopes.keys.reject { |k| k == :scoped }
          @valid_scope_names.include?(name.to_sym)
        end
    end
  end
end