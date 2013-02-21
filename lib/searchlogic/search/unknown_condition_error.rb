module Searchlogic
  class Search
    class UnknownConditionError < ::Object::StandardError
      def initialize(condition)
        msg = "The #{condition} is not a valid condition. You may only use conditions that are defined with scope_procedure"
        puts msg
      end
    end
  end
end