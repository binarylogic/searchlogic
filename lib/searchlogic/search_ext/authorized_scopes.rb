module Searchlogic
  module SearchExt
    module AuthorizedScopes
    
      private
        def known_scopes        
          predefined = %w{_any greater_than_or_equal_to less_than_or_equal_to _or_ _equals _begins_with _does_not_equal _does_not_begin_with ends_with does_not_end_with not_like _like greater_than less_than not_null _null not_blank blank ascend_by descend_by _type}
          aliases = %w{ _is _eq _not_equal_to _is_not _not _ne _lt _before _less_than_or_equal _greater_than_or_equal _lte _gt _after _gte _contains _includes _does_not_include _bw _not_begin_with _ew _not_end_with _nil _not_nil _present}
          custom = klass.named_scopes
          predefined + aliases + custom
        end
        
        def authorized_scope?(scope) 
          !!(known_scopes.detect{ |ks| scope.to_s.include?(ks.to_s)} || ordering?(scope))
        end
        
        def associated_column?(scope_name)
          !!(klass.reflect_on_all_associations.detect{|associaton| scope_name.to_s.include?(associaton.name.to_s)})
        end
    end
  end
end