module Searchlogic
  module ScopeReflectionExt
    module ClassLevelVariables
      ##Class Instance Variables
      def method
        @method
      end

      def method=(method)
        @method = method
      end

      def defined_named_scopes
        @defined_named_scopes ||= {}
      end
    end
  end
end