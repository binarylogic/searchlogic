module Searchlogic
  module ScopeReflectionExt
    module Aliases
      def not_blank_alias
        %w{_present}
      end

      def equals_alias
        %w{_eq _is _equal}
      end

      def does_not_equal_alias
        %w{_not_equal_to _is_not _not _ne _not_equal}
      end

      def less_than_alias
        %w{_lt _before}
      end

      def greater_than_alias
        %w{_gt _after}
      end

      def less_than_or_equal_to_alias
        %w{_lte _less_than_or_equal}
      end

      def greater_than_or_equal_to_alias
        %w{_gte _greater_than_or_equal}
      end

      def not_like_alias
        %w{_does_not_include}
      end

      def like_alias
        %w{_contains _includes _has}
      end

      def begins_with_alias
        %w{_bw}
      end

      def does_not_begin_with_alias
       %w{_not_begin_with}
      end

      def ends_with_alias
        %w{_ew}
      end

      def does_not_end_with_alias
        %w{_not_end_with}
      end

      def null_alias
        %w{_nil}
      end

      def not_null_alias
        %w{_not_nil}
      end
    end
  end
end