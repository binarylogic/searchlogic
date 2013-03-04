module Searchlogic
  module ScopeReflectionExt
    module Aliases
      def alias_hash
        {
          :not_blank => %w{_present},
          :equals => %w{_eq _is _equal},
          :does_not_equal => %w{_not_equal_to _is_not _not _ne _not_equal},
          :less_than => %w{_lt _before},
          :greater_than => %w{_gt _after},
          :less_than_or_equal_to =>  %w{_lte _less_than_or_equal},
          :greater_than_or_equal_to => %w{_gte _greater_than_or_equal},
          :not_like => %w{_does_not_include},
          :like => %w{_contains _includes _has},
          :begins_with => %w{_bw},
          :does_not_begin_with => %w{_not_begin_with},
          :ends_with => %w{_ew},
          :does_not_end_with =>  %w{_not_end_with},
          :null => %w{_nil},
          :not_null => %w{_not_nil},
        }
      end
    end
  end
end