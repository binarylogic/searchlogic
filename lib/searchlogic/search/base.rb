module Searchlogic
  class Base < BasicObject
    def initialize(klass, conditions)
      @klass = klass
      @conditions = ignore_nils(conditions)
    end
    private
      def ignore_nils(conditions)
        conditions.select{|k, v| !v.nil? } 
      end
  end
end