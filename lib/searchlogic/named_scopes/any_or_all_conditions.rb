module Searchlogic
  module NamedScopes
    module AnyOrAllConditions
      # Add any / all variations to every comparison and wildcard condition
      COMPARISON_CONDITIONS.merge(WILDCARD_CONDITIONS).each do |condition, aliases|
        CONDITIONS[condition] = aliases
        CONDITIONS["#{condition}_any".to_sym] = aliases.collect { |a| "#{a}_any".to_sym }
        CONDITIONS["#{condition}_all".to_sym] = aliases.collect { |a| "#{a}_all".to_sym }
      end

      CONDITIONS[:equals_any] = CONDITIONS[:equals_any] + [:in]
      CONDITIONS[:does_not_equal_all] = CONDITIONS[:does_not_equal_all] + [:not_in]
    end

    def condition?(name)

    end

  end
end