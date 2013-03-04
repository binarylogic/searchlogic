module Searchlogic
  module SearchExt
    module AuthorizedScopes
    
      private
        def known_scopes        
          Searchlogic::ScopeReflection.recognized_scopes
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