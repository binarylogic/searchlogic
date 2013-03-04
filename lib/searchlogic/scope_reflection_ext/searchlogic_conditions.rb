module Searchlogic
  module ScopeReflectionExt
    module SearchlogicConditions
      def searchlogic_methods
        ActiveRecord::Base.all_matchers
      end

      def recognized_scopes
        searchlogic_methods + aliases
      end
    end
  end
end