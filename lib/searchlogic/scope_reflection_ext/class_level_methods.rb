module Searchlogic
  module ScopeReflectionExt
    module ClassLevelMethods
      def method
        @method
      end

      def method=(method)
        @method = method
      end

      def authorized?(method)
        new(method).authorized?
      end
    end
  end
end