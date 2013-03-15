Dir[File.dirname(__FILE__) + '/errors/*.rb'].each { |f| require(f) }
module Searchlogic
  module ActiveRecordExt
    module Scopes
      class InvalidConditionError < StandardError
        def initialize(error)
          message = error.name.to_s.gsub(/=$/, "")
          msg = "`#{message}' is an invalid condition"
          super(msg)
        end
      end
    end
  end
end
