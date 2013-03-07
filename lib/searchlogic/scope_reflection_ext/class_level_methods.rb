module Searchlogic
  module ScopeReflectionExt
    module ClassLevelMethods
      def method
        @method
      end

      def method=(method)
        @method = method
      end

    end
  end
end