Dir[File.dirname(__FILE__) + '/errors/*.rb'].each { |f| require(f) }
module Searchlogic
  module ActiveRecordExt
    module Scopes
      class InvalidConditionError < StandardError
        def initialize(error)
          msg = "#{error.name.to_s} is an invalid condition. You probably misspelled a column or left off a condition"
          super(msg)
        end
      end
    end
  end
end
