module Searchlogic
  class Base < BasicObject
    def initialize(klass, conditions)
      @klass = klass
    end
    private
  end
end