module Searchlogic
  class Search < Base
    module AuthorizedScopes
      def known_scopes        
        predefined = %w{_any greater_than_or_equal_to less_than_or_equal_to or equals begins_with does_not_equal does_not_begin_with ends_with does_not_end_with not_like like greater_than less_than not_null null not_blank blank ascend_by descend_by type}
        aliases = %w{ is eq not_equal_to is_not not ne lt before less_than_or_equal greater_than_or_equal lte gt after gte contains includes does_not_include bw not_begin_with ew not_end_with nil not_nil present}
        custom = ActiveRecord::Base.searchlogic_scopes
        predefined + aliases + custom
      end
      def authorized_scope?(scope) 
        !!(known_scopes.detect{ |ks| scope.to_s.include?(ks.to_s)})
      end
    end
  end
end