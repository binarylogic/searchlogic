module Searchlogic
  # Active Record is pretty inconsistent with how their SQL is constructed. This
  # method attempts to close the gap between the various inconsistencies.
  module ActiveRecordConsistency
    def self.included(klass)
      klass.class_eval do
        alias_method_chain :merge_joins, :searchlogic
      end
    end
    
    # In AR multiple joins are sometimes in a single join query, and other time they
    # are not. The merge_joins method in AR should account for this, but it doesn't.
    # This fixes that problem.
    def merge_joins_with_searchlogic(*args)
      joins = merge_joins_without_searchlogic(*args)
      joins.collect { |j| j.is_a?(String) ? j.split("  ") : j }.flatten.uniq
    end
  end
end

module ActiveRecord # :nodoc: all
  class Base
    class << self
      include Searchlogic::ActiveRecordConsistency
    end
  end
end