module Searchlogic
  module SearchExt
    module UnknownConditionError
      class UnknownConditionError < ::Object::StandardError
        def initialize(condition)
          msg = "'#{condition}' is not a valid condition. In order to use custom conditions you must define them with 'scope_procedure'"
          puts msg
        end
      end
    end
  end
end