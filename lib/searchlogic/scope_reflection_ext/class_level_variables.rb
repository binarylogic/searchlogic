module Searchlogic
  module ScopeReflectionExt
    module ClassLevelVariables
      
      def method
        @method
      end

      def method=(method)
        @method = method
      end
    end
  end
end