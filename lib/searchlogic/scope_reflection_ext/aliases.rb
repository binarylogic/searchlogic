module Searchlogic
  module ScopeReflectionExt
    module Aliases
      def alias_hash
        {
          :_not_blank => %w{_present},
          :_equals => %w{_eq _is _equal},
          :_does_not_equal => %w{_not_equal_to _is_not _not _ne _not_equal},
          :_less_than => %w{_lt _before},
          :_greater_than => %w{_gt _after},
          :_less_than_or_equal_to =>  %w{_lte _less_than_or_equal},
          :_greater_than_or_equal_to => %w{_gte _greater_than_or_equal},
          :_not_like => %w{_does_not_include},
          :_like => %w{_contains _includes _has},
          :_begins_with => %w{_bw},
          :_does_not_begin_with => %w{_not_begin_with},
          :_ends_with => %w{_ew},
          :_does_not_end_with =>  %w{_not_end_with},
          :_null => %w{_nil},
          :_not_null => %w{_not_nil},
        }
      end

      def aliases
        alias_hash.collect{|k,v| v }.flatten
      end

    end
  end
end