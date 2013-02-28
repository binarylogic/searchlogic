Dir[File.dirname(__FILE__) + '/chained_conditions/*.rb'].each { |f| require(f) }
module Searchlogic
  module SearchExt
    module ChainedConditions
      def chained_conditions(sanitized_conditions = self.conditions)          
        scope_generator = ScopeGenerator.new(sanitized_conditions, klass)
        scope_generator.scope_conditions.empty? ? scope_generator.initial_scope : scope_generator.full_scope
      end
    end
  end
end