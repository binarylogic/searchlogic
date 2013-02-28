Dir[File.dirname(__FILE__) + '/chained_conditions/*.rb'].each { |f| require(f) }
module Searchlogic
  module SearchExt
    module ChainedConditions
      def chained_conditions(sanitized_conditions = self.conditions)          
        scope_generator = ScopeGenerator.new(sanitized_conditions, klass)
        
      end
    end
  end
end