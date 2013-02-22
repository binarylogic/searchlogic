module Searchlogic
  class Search < Base
    include Each
    include Attributes
    include ChainedConditions
    include ReaderWriter
    include Ordering
    include MethodMissing
    include Delegate
    include AuthorizedScopes 
    def initialize(klass, conditions)
      super
      @conditions = sanitize(conditions)
    end


    private
    def sanitize(conditions)
      conditions.select{ |k, v| !v.nil? && (authorized_scope?(k) || column_name?(k)) }
    end
    def column_name?(scope)
      !!(klass.column_names.detect{|kcn| scope.downcase.to_s.include?(kcn.downcase)})
    end    
  end
end
