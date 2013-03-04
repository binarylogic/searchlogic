module Searchlogic
  module ScopeReflectionExt
    module SearchlogicConditions
      def searchlogic_methods
        ActiveRecord::Base.all_matchers
      end
    end
  end
end