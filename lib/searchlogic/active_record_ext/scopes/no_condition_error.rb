Dir[File.dirname(__FILE__) + '/errors/*.rb'].each { |f| require(f) }
module Searchlogic
  module ActiveRecordExt
    module Scopes
      class NoConditionError < StandardError
        def initialize
          msg = "There was no condition defined on the method, perhaps you misspelled it"
          super(msg)
        end
      end
    end
  end
end
