module Searchlogic
  module SearchExt
    module UnknownConditionError
      class UnknownConditionError < StandardError
        def initialize(condition)
          msg = "'#{condition}' is not a valid condition. In order to use custom conditions you must define them with 'named_scopes'"
          StandardError.new(msg)
        end
      end
    end
  end
end