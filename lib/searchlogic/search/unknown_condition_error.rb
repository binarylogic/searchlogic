module Searchlogic
  class Search
    # Is an invalid condition is used this error will be raised. Ex:
    #
    #   User.search(:unkown => true)
    #
    # Where unknown is not a valid named scope for the User model.
    class UnknownConditionError < StandardError
      def initialize(condition)
        msg = "The #{condition} is not a valid condition. You may only use conditions that map to a named scope"
        super(msg)
      end
    end
  end
end