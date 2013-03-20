module Searchlogic
  module ScopeReflectionExt
    class UninitializedClassError < StandardError
      def initialize
        msg = "You must initialize ScopeReflection with a class in order to call this method"
        super(msg)
      end
    end 
  end
end
