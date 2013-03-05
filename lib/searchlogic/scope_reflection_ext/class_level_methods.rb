module Searchlogic
  module ScopeReflectionExt
    module ClassLevelMethods
      ##Class level method
      def method
        @method
      end

      def method=(method)
        @method = method
      end

    end
  end
end