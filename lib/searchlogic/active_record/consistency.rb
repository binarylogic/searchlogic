module Searchlogic
  module ActiveRecord
    # Active Record is pretty inconsistent with how their SQL is constructed. This
    # method attempts to close the gap between the various inconsistencies.
    module Consistency
      def self.included(klass)
        klass.class_eval do
          alias_method_chain :merge_joins, :singularity
          alias_method_chain :merge_joins, :consistent_conditions
          alias_method_chain :merge_joins, :merged_duplicates
        end
      end
      
      # In AR multiple joins are sometimes in a single join query, and other times they
      # are not. The merge_joins method in AR should account for this, but it doesn't.
      # This fixes that problem. This way there is one join per string, which allows
      # the merge_joins method to delete duplicates.
      def merge_joins_with_singularity(*args)
        joins = merge_joins_without_singularity(*args)
        joins.collect { |j| j.is_a?(String) ? j.split("  ") : j }.flatten.uniq
      end
      
      # This method ensures that the order of the conditions in the joins are the same.
      # The strings of the joins MUST be exactly the same for AR to remove the duplicates.
      # AR is not consistent in this approach, resulting in duplicate joins errors when
      # combining scopes.
      def merge_joins_with_consistent_conditions(*args)
        joins = merge_joins_without_consistent_conditions(*args)
        joins.collect do |j|
          if j.is_a?(String) && (j =~ / (AND|OR) /i).nil?
            j.gsub(/(.*) ON (.*) = (.*)/) do |m|
              join, cond1, cond2 = $1, $2, $3
              sorted = [cond1.gsub(/\(|\)/, ""), cond2.gsub(/\(|\)/, "")].sort
              "#{join} ON #{sorted[0]} = #{sorted[1]}"
            end
          else
            j
          end
        end.uniq
      end
      
      
      def merge_joins_with_merged_duplicates(*args)
        args << "" if !Thread.current["searchlogic_delegation"]
        joins = merge_joins_without_merged_duplicates(*args)
      end
    end
  end
end