Dir[File.dirname(__FILE__) + '/errors/*.rb'].each { |f| require(f) }
module Searchlogic
  module ActiveRecordExt
    module Scopes
      class NoConditionError < StandardError
        def initialize(error)
          msg = "There was no condition defined on the method. #{error.message}"
          super(msg)
        end
      end
    end
  end
end
