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
    end
  end
end