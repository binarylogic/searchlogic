module Searchlogic
  module ScopeReflectionExt
    module ClassLevelMethods
      def authorized?(method)
        new(method).authorized?
      end
    end
  end
end